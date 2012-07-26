require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :addresses, :flavors, :instances, :security_groups, :volumes, :current_project
  attr_accessor :private_keys

  def initialize
    initialize_service Compute

    @addresses = service.addresses
    @flavors   = service.flavors
    @instances = service.servers
    @volumes   = service.volumes
    @security_groups = service.security_groups

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

    # Get smallest-sized flavor
    min_flavor = service.flavors.select { |f| f.disk > 0 }.min { |f, g| f.vcpus <=> g.vcpus }

    attributes[:name]     ||= Faker::Name.name
    attributes[:password] ||= test_instance_password || '123qwe'
    attributes[:image]    ||= service.images[5].id || service.images[2].id
    attributes[:flavor]   ||= min_flavor.id
    attributes[:key_name] ||= service.key_pairs[0] && service.key_pairs[0].name
    
    if service.list_servers.body['servers'].none? { |s| s['name'] == attributes[:name] }
      begin
        service.create_server(
          attributes[:name],
          attributes[:image],
          attributes[:flavor],
          {
            'tenant_id'      => project.id,
            'key_name'       => attributes[:key_name],
            'security_group' => service.security_groups[0].id,
            'user_id'        => service.current_user['id']
          }
        )
      rescue => e
        raise "Couldn't initialize instance in #{ project.name }. " +
              "The error returned was: #{ e.inspect }"
      end
    end

    sleeping(ConfigFile.wait_long).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      instance = find_instance_by_name(project, attributes[:name])
      if instance.state =~ /ERROR|SHUTOFF/
        break # No use retrying if instance is in error state
      elsif instance.state != 'ACTIVE'
        raise "Instance #{ instance.name } took too long to become active. " +
              "Instance is currently #{ instance.state }."
      else
        return instance
      end
    end

    raise "Instance #{ instance.name } is in #{ instance.state } status." if instance.state =~ /ERROR|SHUTOFF/
  end

  def create_instances_in_project(project, desired_count)
    service.set_tenant project
    instances.reload

    # Delete any error or shutoff instances first
    error_instances    = instances.select { |i| i.state =~ /^ERROR|SHUTOFF$/ }
    inactive_instances = instances.select { |i| i.state !~ /^ACTIVE|ERROR|SHUTOFF$/ } # Changed from =~ to !~

    error_instances.each do |instance|
      instance.destroy
      sleep(ConfigFile.wait_short) # Don't send too many requests at once
    end

    inactive_instances.each do |instance|
      activate_instance(instance)
    end

    active_instances = instances.reload.select{ |i| i.state == 'ACTIVE' }
    if active_instances.count < desired_count
      desired_count.times do
        create_instance_in_project(project)
        sleep(ConfigFile.wait_short)
      end

      active_instances = instances.reload.select{ |i| i.state =~ /^ACTIVE$/ }
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
    remove_attached_instance_resources(instance)

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
      address_attributes = { ip: address.ip, id: address.id }
      if instance_ids.include?(address.instance_id) && !address.instance_id.blank?
        address_attributes.merge!( instance_id: address.instance_id )
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
          sleep(ConfigFile.wait_short)
        end
      elsif strict && desired_count < attached_volumes.count
        (attached_volumes.count - desired_count).times do |i|
          service.detach_volume(instance.id, attached_volumes[i].id)
          sleep(ConfigFile.wait_short)
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

  def ensure_keypair_exists(key_name, username='', password='')
    # Keypairs are user-scoped, thus the need to login to the compute service
    # with the current user's credentials.
    unless username.blank? || password.blank?
      credentials = ConfigFile.cloud_credentials.merge(
        openstack_username: username, openstack_api_key: password)
      user_service = Fog::Compute.new(credentials)
    else
      user_service = service
    end

    keypairs = user_service.key_pairs.reload
    if keypair = keypairs.find { |keypair| keypair.name == key_name }
      keypair.destroy
    end
    response = user_service.create_key_pair(key_name)
    private_keys[key_name] = response.body['keypair']['private_key']
    public_key = response.body['keypair']['public_key']

    keypairs = service.key_pairs.reload
    if keypair = keypairs.find { |keypair| keypair.name == key_name }
      keypair.destroy
    end
    service.create_key_pair(key_name, public_key)

    return keypairs.reload.find { |keypair| keypair.name == key_name }
  rescue => e
    raise "Couldn't create keypair '#{ key_name }'! The error returned " +
          "was #{ e.inspect }."
  end

  def ensure_project_floating_ip_count(project, desired_count, instance=nil)
    set_tenant project

    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      addresses = service.addresses
      actual_count = addresses.count

      if desired_count > actual_count

        how_many = desired_count - actual_count
        how_many.times do |n|
          service.allocate_address
          sleep(ConfigFile.wait_short)
        end
        addresses.reload


      elsif desired_count < addresses.length

        while addresses.length > desired_count
          addresses.reload
          addresses[0].destroy rescue nil
        end

      end

      # Floating IPs should usually be associated to an instance
      unless instance.nil? && instance.id.blank?
        desired_count.times do |n|
          if addresses[n] && !addresses[n].ip.blank?
            service.associate_address(instance.id, addresses[n].ip)
            sleep(ConfigFile.wait_short)
          end
        end
      end

      addresses.reload
      addresses = addresses.select { |a| a.instance_id == instance.id } unless instance.nil? && instance.id.blank?
      if addresses.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "floating IPs. Current number of floating IPs is #{ addresses.length }."
      end

      return addresses.count
    end
  end

  def ensure_project_does_not_have_floating_ip(project, desired_count, instance)
    set_tenant project

    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      addresses = service.addresses
      actual_count = addresses.count

      if desired_count > actual_count

        how_many = desired_count - actual_count
        how_many.times do |n|
          service.allocate_address
          sleep(ConfigFile.wait_short)
        end
        addresses.reload


      elsif desired_count < addresses.length

        while addresses.length > desired_count
          addresses.reload
          addresses[0].destroy rescue nil
        end

      end

      # Floating IPs should usually be associated to an instance
      unless instance.nil? && instance.id.blank?
        desired_count.times do |n|
          if addresses[n] && !addresses[n].ip.blank?
            service.associate_address(instance.id, addresses[n].ip)
            sleep(ConfigFile.wait_short)
          end
        end
      end

      addresses.reload
      addresses = addresses.select { |a| a.instance_id == instance.id } unless instance.nil? && instance.id.blank?
      if addresses.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "floating IPs. Current number of floating IPs is #{ addresses.length }."
      end

      return addresses.count
    end
  end

  def ensure_active_instance_count(project, desired_count, strict = true)
    ensure_instance_count(project, :active, desired_count, strict)
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

  def set_tenant(project, reload = true)
    if @current_project != project
      @current_project = project
      service.set_tenant(project)
    end
    if reload
      addresses.reload
      instances.reload
    end
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
    service.set_tenant project
    instance = service.servers.find_by_name(name)
    instance
  end

  def find_security_group_by_name(project, name)
    service.set_tenant project
    security_groups = service.security_groups
    security_groups.find_by_name(name)
    security_groups
  end

  def get_project_instances(project)
    service.set_tenant project
    instances.reload
    instances
  end

  def set_tenant(project, reload = true)
    if @current_project != project
      @current_project = project
      service.set_tenant(project)
    end
    if reload
      @addresses = service.addresses
      @flavors   = service.flavors
      @instances = service.servers
      @volumes   = service.volumes
    end
  end

  def set_tenant!(project)
    @current_project = project
    service.set_tenant(project)

    @addresses = service.addresses
    @flavors   = service.flavors
    @instances = service.servers
    @volumes   = service.volumes
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

  def check_building_project_instance_progress(instances, expected_count)
    keep_trying(wait: 5.seconds) do
      count = instances.count { |i| i.state == 'ACTIVE' }
      if count < expected_count
        raise "Instances are taking too long to build! " +
              "Expected #{ expected_count } building instances to be active."
      end
    end
  end

  # Ensures that there are `desired_count` number of instances in the project
  # Set `strict` to false if you don't mind having more than `desired_count`
  # number of instances in the project.
  def ensure_instance_count(project, status, desired_count, strict = true)
    status = status.to_s.upcase
    service.set_tenant project

    # This block will keep running until it stops raising an error, or until
    # the max number of tries is reached. In the last try, whatever error is
    # raised by the block is thrown.
    # 60 tries is needed for rebooting instances so please don't change it.
    # Since instance reboot will take a while.
    sleeping(ConfigFile.wait_long).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do

      status_instances = instances.reload.select { |i| i.state == status }
      delta_count      = (desired_count - status_instances.count).abs

      if desired_count > status_instances.count
        active_instances = create_instances_in_project(project, delta_count)

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

  def remove_attached_instance_resources(instance)
    associated_addresses = addresses.select { |a| a.instance_id == instance.id }
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
