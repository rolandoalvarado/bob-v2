require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :addresses, :flavors, :instances, :security_groups, :volumes,
    :images, :key_pairs, :current_project, :current_user
  attr_accessor :private_keys

  def initialize
    initialize_service Compute

    @addresses = service.addresses
    @instances = service.servers
    @volumes   = service.volumes
    @security_groups = service.security_groups
    @key_pairs = service.key_pairs

    @private_keys = {}
  end

  def attach_volume_to_instance_in_project(project, instance, volume)
    set_tenant project, false
    volume      = volumes.find { |v| v.id == volume['id'].to_i }
    device_name = "/dev/vd#{ ('a'..'z').to_a.sample(2).join }"

    begin
      service.attach_volume(volume.id, instance.id, device_name)
    rescue => e
      raise "Couldn't attach volume #{ volume.name } to instance #{ instance.name }! " +
            "The error returned was: #{ e.inspect }"
    end

    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      volumes.reload
      volume = volumes.get(volume.id)
      unless volume.attachments.any? { |a| a['server_id'] == instance.id }
        raise "Couldn't ensure that instance #{ instance.name } has attached volume #{ volume.name }!"
      end
    end
  end

  def create_instance_in_project(project, attributes={})
    set_tenant project

    @flavors ||= service.flavors
    @images  ||= ImageService.session.get_bootable_images

    if attributes[:flavor].is_a? String
      attributes[:flavor] = flavor_from_name(attributes[:flavor])
    end

    attributes[:name]           ||= Faker::Name.name
    attributes[:password]       ||= test_instance_password || '123qwe'
    attributes[:image]          ||= @images.sample.id
    attributes[:flavor]         ||= @flavors.find { |f| f.name == 'm1.small' }.id
    attributes[:key_name]       ||= @key_pairs[0] && @key_pairs[0].name

    if attributes[:security_group]
      @security_groups.each do |sg|
        if sg.name.match Regexp.new(attributes[:security_group])
          @security_group_array = [{ :name => sg.name }]
        end
      end
    else
      @security_group_array = [{ :name => @security_groups[0].name }]
    end

    instance = @instances.find do |i|
      # ensure flavor is also the same (currently only for @resize tests)
      i.name == attributes[:name] and i.flavor['id'] == attributes[:flavor]
    end

    unless instance
      begin
        response = service.create_server(
          attributes[:name],
          attributes[:image],
          attributes[:flavor],
          {
            'tenant_id'       => project.id,
            'key_name'        => attributes[:key_name],
            'security_groups' => @security_group_array,
            'user_id'         => service.current_user['id']
          }
        )
        instance = @instances.reload.get(response.body['server']['id'])
      rescue => e
        raise "Couldn't initialize instance in #{ project.name }. " +
              "The error returned was: #{ e.inspect }"
      end
    end

    wait_period = ConfigFile.wait_instance_launch + Time.now().to_i
    while wait_period >= Time.now().to_i
      instance.reload
      case instance.state
      when /BUILD|REVERT_RESIZE/
        sleep ConfigFile.wait_short
      when /ACTIVE/
        return instance
      when /PAUSED|SUSPENDED|VERIFY_RESIZE/
        activate_instance(instance)
        sleep ConfigFile.wait_short
      when /ERROR|SHUTOFF/
        break
      end
    end

    raise "Instance #{ instance.name } is still in #{ instance.state } status."
  end

  def create_instances_in_project(project, desired_count, attributes = {})
    service.set_tenant project
    @instances.reload

    active_instances = []
    if @instances.count > 0
      # Delete any error or shutoff instances first
      error_instances    = @instances.select { |i| i.state =~ /^ERROR|SHUTOFF$/ }
      inactive_instances = @instances.select { |i| i.state !~ /^ACTIVE|ERROR|SHUTOFF$/ }

      error_instances.each do |instance|
        instance.destroy
        sleep(ConfigFile.wait_short) # Don't send too many requests at once
      end

      inactive_instances.each do |instance|
        activate_instance(instance)
      end

      active_instances = @instances.reload.select{ |i| i.state == 'ACTIVE' }
    end

    if active_instances.count < desired_count
      desired_count.times do
        create_instance_in_project(project, attributes)
      end

      active_instances = @instances.reload.select{ |i| i.state == 'ACTIVE' }
    end

    active_instances
  end

  def create_volume(attributes = {})
    attrs = CloudObjectBuilder.attributes_for(:volume)
    attrs.merge!(attributes)

    if service.volumes.none? { |v| v.name == attrs.name }
      service.create_volume(attrs.name, attrs.description, attrs.size)
    end
  end

  # Delete instance and detach it from the resources that depend on it
  def delete_instance_in_project(project, instance)
    set_tenant project

    activate_instance(instance)
    remove_attached_instance_resources(project, instance)

    begin
      instance.destroy
    rescue => e
      raise "Couldn't delete instance #{ instance.name } in #{ project.name }. " +
            "The error returned was: #{ e.inspect }."
    end
  end

  def delete_instances_in_project(project)
    deleted_instances = []
    set_tenant project
    project_instances = instances.find_all{ |i| i.tenant_id == project.id }
    attached_volumes  = service.volumes.select{ |v| !v.attachments.empty? && v.attachments.none?(&:empty?) }

    # There seems to be a bug in OpenStack. Sometimes this fails,
    # sometimes this works just fine.
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      service.set_tenant 'admin'
    end

    if project_instances
      project_instances.each do |instance|
        deleted_instances << { name: instance.name, id: instance.id }
        sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
          delete_instance_in_project(project, instance)
        end
      end
    end

    deleted_instances
  end

  def detach_volume_from_instance_in_project(project, instance, volume)
    set_tenant project
    volume = volumes.find { |v| v.id == volume['id'].to_i }

    # Check if volume is attached to the instance
    if volume.attachments.any? { |a| a['server_id'] == instance.id }
      begin
        service.detach_volume(instance.id, volume.id)
      rescue => e
        raise "Couldn't detach volume #{ volume.name } from instance #{ instance.name }! " +
              "The error returned was: #{ e.inspect }"
      end
    end

    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      volumes.reload
      volume = volumes.get(volume.id)
      if volume.attachments.any? { |a| a['server_id'] == instance.id }
        raise "Couldn't ensure that instance #{ instance.name } has no attached volume #{ volume.name }!"
      end
    end
  end

  def release_addresses_from_project(project)
    released_addresses = []
    set_tenant project
    instance_ids = instances.select { |i| i.state == 'ACTIVE' }.collect(&:id)

    addresses.each do |address|
      address_attributes = { ip: address.ip, id: address.id, instance_id: address.instance_id }
      if instance_ids.include?(address.instance_id) && !address.instance_id.blank?
        service.disassociate_address(address.instance_id, address.ip)
      end

      service.release_address(address.id)
      released_addresses << address_attributes
    end

    released_addresses
  end

  def ensure_instance_attached_volume_count(project, instance, desired_count, strict = true)
    set_tenant project, false

    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      volumes = service.volumes
      if desired_count > volumes.count
        (desired_count - volumes.count).times do
          create_volume
          sleep(ConfigFile.wait_short)
        end
      end

      volumes.reload
      raise "Requires #{ desired_count } volumes. Only #{ volumes.count } volumes exist!" if desired_count > volumes.count

      attached_volumes     = volumes.select{ |v| v.attachments.any?{ |a| a['server_id'] == instance.id } }
      non_attached_volumes = volumes.select{ |v| v.attachments.first.empty? }
      if desired_count > attached_volumes.count
        (desired_count - attached_volumes.count).times do |i|
          service.attach_volume(non_attached_volumes[i].id, instance.id, '/dev/vdc')
          sleep(ConfigFile.attach_volume)
        end
      elsif strict && desired_count < attached_volumes.count
        (attached_volumes.count - desired_count).times do |i|
          service.detach_volume(instance.id, attached_volumes[i].id)
          sleep(ConfigFile.detach_volume)
        end
      end

      volumes.reload
      attached_volumes = volumes.select{ |v| v.attachments.any?{ |a| a['server_id'] == instance.id } }
      if strict && desired_count != attached_volumes.count
        raise "Couldn't ensure instance #{ instance.name } has #{ desired_count } attached volumes."
      elsif !strict && desired_count > attached_volumes.count
        raise "Couldn't ensure instance #{ instance.name } has at least #{ desired_count } attached volumes."
      end

      return attached_volumes.count
    end
  end

  def ensure_keypair_exists(key_name)
    keypairs = service.key_pairs
    if keypair = keypairs.find { |k| k.name == key_name }
      keypair.destroy
      sleep(1)
    end

    response = service.create_key_pair(key_name)
    @private_keys[key_name] = response.body['keypair']['private_key']

    return keypairs.reload.find { |keypair| keypair.name == key_name }
  rescue => e
    raise "Couldn't create keypair '#{ key_name }'! The error returned " +
          "was: #{ e.inspect }"
  end

  def ensure_project_floating_ip_count(project, desired_count, instance=nil)
    set_tenant project

    actual_count = @addresses.count

    if desired_count > actual_count

      if instance
        @addresses.each do |address|
          address.server = instance
          address.save
          sleep(ConfigFile.wait_short)
        end
      end

      while @addresses.length < desired_count
        @addresses.reload
        @addresses.create(server: instance)
        sleep(ConfigFile.wait_short)
      end

    elsif desired_count < @addresses.length

      while @addresses.length > desired_count
        @addresses.reload
        @addresses.first.destroy rescue nil
        sleep(ConfigFile.wait_short)
      end

    end

    # Wait for any addresses that are still being created/associated
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      @addresses.reload
      addresses = @addresses.select { |a| a.instance_id == instance.id } unless instance.nil? && instance.id.blank?
      if addresses.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "floating IPs. Current number of floating IPs is #{ addresses.length }."
      end

      return addresses.count
    end
  end

  def ensure_active_instance_count(project, desired_count, strict = true, attributes = {})
    ensure_instance_count(project, :active, desired_count, strict, attributes)
  end

  def ensure_paused_instance_count(project, desired_count, strict = true)
    ensure_instance_count(project, :paused, desired_count, strict)
  end

  def ensure_suspended_instance_count(project, desired_count, strict = true)
    ensure_instance_count(project, :suspended, desired_count, strict)
  end

  def ensure_project_instance_is_active(project, name)
    service.set_tenant project
    keep_trying do
      instances.reload

      instance_search = instances.select { |i| i.name == name }
      instance = instance_search.last

      if instance
        if instance.state != 'ACTIVE'
          while instances.include?(instance)
            instances.reload
            instance.destroy rescue nil
          end

          instance = create_instance_in_project(project, { name:   instance.name,
                                                           image:  instance.image['id'],
                                                           flavor: instance.flavor['id'] })
        end
      else
        instance = create_instance_in_project(project, { name:   instance.name,
                                                         image:  instance.image['id'],
                                                         flavor: instance.flavor['id'] })
      end

      if instance.state != 'ACTIVE'
        raise "Couldn't ensure that instance #{ name } in #{ project.name }" +
              "is active."
      end

      return instance
    end
  end

  def ensure_instance_is_rebooted_and_active(project, instance)
    service.set_tenant project
    instance.reboot("HARD")

    sleeping(ConfigFile.wait_long).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      instances.reload

      instance_search = instances.select { |i| i.name == instance.name }
      instance = instance_search.last

      if instance.state != 'ACTIVE'
        raise "Couldn't ensure that instance #{ instance.name } in #{ project.name }" +
              "is active."
      end

      return instance
    end
  end

  def ensure_security_group_rule(project, ip_protocol='tcp', from_port=22, to_port=22, cidr='0.0.0.0/0')
    service.set_tenant project
    security_group = service.security_groups.first
    parent_group_id = security_group.id

    # Ensure that there are no security group rule before adding anything
    security_group.rules.each do |r|
      service.delete_security_group_rule(r['id'])
    end

    #Create Rule for SSH
    service.create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr)

    #Create Rule for ICMP, needed for accessing ssh using Public ip.
    icmp_protocol = 'icmp'
    icmp_from_port = -1
    icmp_to_port = -1
    icmp_cidr = '0.0.0.0/0'
    service.create_security_group_rule(parent_group_id, icmp_protocol, icmp_from_port, icmp_to_port, icmp_cidr)
  rescue => e
    raise "Couldn't ensure security group rule exists! The error returned was #{ e.inspect }"
  end

  def ensure_security_group_rule_exist(project, ip_protocol='tcp', from_port=22, to_port=22, cidr='0.0.0.0/0')
    service.set_tenant project
    security_group = service.security_groups.first
    parent_group_id = security_group.id

    # Ensure that there are no security group rule before adding anything
    security_group.rules.each do |r|
      service.delete_security_group_rule(r['id'])
    end

    service.create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr)

  rescue => e
    raise "Couldn't ensure security group rule exists! The error returned was #{ e.inspect }"
  end

  def create_security_group(project, attributes)
    service.set_tenant project
    security_groups = service.security_groups

    find_security_group = security_groups.find_by_name(attributes[:name])
    find_security_group.destroy if find_security_group

    security_group = security_groups.new(attributes)
    security_group.save
    security_group
  end

  def delete_security_group(security_group)
    security_group.destroy
  end

  def ensure_security_group_exists(project, attributes)
    service.set_tenant project
    find_security_group = service.security_groups.find_by_name(attributes[:name]) rescue nil

    find_security_group.destroy if find_security_group

    security_group = create_security_group(project, attributes)
  end

  def ensure_project_security_group_count(project, desired_count)
    service.set_tenant project
    security_groups = service.security_groups
    security_groups_count = security_groups.count

    if desired_count < security_groups_count
      i = security_groups_count
      while i > desired_count
        security_groups.reload
        security_groups[i].destroy rescue nil
        i = i - 1
      end
    end
    security_groups
  end

  def ensure_security_group_does_not_exist(project, attributes)
    service.set_tenant project

    security_groups = service.security_groups

    if find_security_group = security_groups.find_by_name(attributes[:name])
      delete_security_group(find_security_group)
    end
  end

  def find_security_group_by_name(project, name)
    service.set_tenant project
    security_groups = service.security_groups
    security_groups.find_by_name(name)
    security_groups
  end

  def create_security_group(project, attributes)
    service.set_tenant project
    security_groups = service.security_groups
    find_security_group = security_groups.find_by_name(attributes[:name])

    find_security_group.destroy if find_security_group

    security_group = security_groups.new(attributes)
    security_group.save
    security_group
  end

  def delete_security_group(security_group)
    security_group.destroy
  end

  def ensure_security_group_exists(project, attributes)
    service.set_tenant project
    security_groups = service.security_groups
    find_security_group = security_groups.find_by_name(attributes[:name]) rescue nil

    if find_security_group
      security_group = find_security_group
    else
      security_group = create_security_group(project, attributes)
    end
    security_group
  end

  def ensure_project_security_group_count(project, desired_count)
    service.set_tenant project
    security_groups = service.security_groups
    security_groups_count = security_groups.count

    if desired_count < security_groups_count
      i = security_groups_count
      while i > desired_count
        security_groups.reload
        security_groups[i].destroy rescue nil
        i = i - 1
      end
    end
    security_groups
  end

  def ensure_security_group_does_not_exist(project, attributes)
    service.set_tenant project
    security_groups = service.security_groups

    if security_group = security_groups.find_by_name(attributes[:name])
      delete_security_group(security_group)
    end
  end

  def find_instance_by_name(project, name)
    set_tenant project, false
    @instances.reload.find_by_name(name)
  end

  def find_security_group_by_name(project, name)
    set_tenant project, false
    @security_groups.reload.find_by_name(name)
  end

  def get_project_instances(project)
    set_tenant project, false
    @instances.reload
  end

  def set_tenant(project, reload = true)
    if @current_project != project
      @current_project = project
      service.set_tenant(project)
    end
    if reload
      @addresses.reload
      @instances.reload
      @volumes.reload
    end
  end

  def set_tenant!(project)
    @current_project = project
    service.set_tenant(project)

    @addresses.reload
    @instances.reload
    @volumes.reload
  end
  
  def pause_an_instance(project, instance)
    service.set_tenant project
    
    sleep(ConfigFile.wait_long)
    service.pause_server(instance.id)
  end

  private

  def activate_instance(instance)
    case instance.state
    when 'SUSPENDED'
      service.resume_server(instance.id)
    when 'PAUSED'
      service.unpause_server(instance.id)
    when 'VERIFY_RESIZE'
      service.revert_resized_server(instance.id)
    end

    true
  end

  # Ensures that there are `desired_count` number of instances in the project
  # Set `strict` to false if you don't mind having more than `desired_count`
  # number of instances in the project.
  def ensure_instance_count(project, status, desired_count, strict = true, attributes = {})
    status = status.to_s.upcase
    service.set_tenant project

    # This block will keep running until it stops raising an error, or until
    # the max number of tries is reached. In the last try, whatever error is
    # raised by the block is thrown.
    # 60 tries is needed for rebooting instances so please don't change it.
    # Since instance reboot will take a while.
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do

      status_instances = instances.reload.select { |i| i.state == status }
      delta_count      = (desired_count - status_instances.count).abs

      if desired_count > status_instances.count
        active_instances = create_instances_in_project(project, delta_count, attributes)

        delta_count.times do |i|
          case status
          when 'PAUSED'
            service.pause_server(active_instances[i].id)
          when 'SUSPENDED'
            service.suspend_server(active_instances[i].id)
          end
          sleep(ConfigFile.wait_short)
        end
      elsif strict && desired_count < status_instances.count
        delta_count.times do |i|
          delete_instance_in_project(project, status_instances[i])
        end
      end

      actual_count = instances.reload.select{ |i| i.state == status }.count
      if strict && desired_count != actual_count
        raise "Couldn't ensure that the project #{ project.name } has " +
              "#{ desired_count } #{ status.downcase } instances! " +
              "Current count is #{ actual_count }."
      elsif !strict && desired_count < actual_count
        raise "Couldn't ensure that the project #{ project.name } has at least " +
              "#{ desired_count } #{ status.downcase } instances! " +
              "Current count is #{ actual_count }."
      else
        return actual_count
      end

    end # sleeping(x).seconds.between_tries.failing_after(y).tries
  end

  def flavor_from_name(name)
    return unless @flavors
    flavor = @flavors.find { |f| f.name == name }
    flavor.id
  end

  def raise_ensure_active_instance_count_error(message, desired_count)
    raise "ERROR: Couldn't ensure #{ desired_count } active instances in project. " +
          message
  end

  def raise_ensure_paused_instance_count_error(message, desired_count)
    raise "ERROR: Couldn't ensure #{ desired_count } paused instances in project. " +
          message
  end

  def raise_ensure_suspended_instance_count_error(message, desired_count)
    raise "ERROR: Couldn't ensure #{ desired_count } suspended instances in project. " +
          message
  end

  def remove_attached_instance_resources(project, instance)
    set_tenant project
    associated_addresses = @addresses.reload.select { |a| a.instance_id == instance.id }
    associated_addresses.each do |address|
      instance.disassociate_address(address.ip)
      sleep(ConfigFile.wait_short)
    end

    attached_volumes = service.volumes.select { |v| v.attachments.any? { |a| a['server_id'] == instance.id } }
    attached_volumes.each do |volume|
      volume.detach
      sleep(ConfigFile.wait_short)
    end

    true
  end

end
