require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :addresses, :flavors, :instances, :security_groups, :current_project

  def initialize
    initialize_service Compute
    @addresses = service.addresses
    @flavors   = service.flavors
    @instances = service.servers
    @security_groups = service.security_groups
  end

  def attach_volume_to_instance_in_project(project, instance, volume)
    set_tenant project, false
    service.attach_volume(volume['id'], instance.id, '/dev/vdz')
    set_tenant 'admin'
  rescue
    raise "Couldn't attach volume #{ volume['display_name'] } to instance #{ instance.name }!"
  end

  def create_instance_in_project(project, attributes={})
    set_tenant project
    attributes[:name]   ||= Faker::Name.name
    attributes[:image]  ||= service.images[0].id
    attributes[:flavor] ||= service.flavors[0].id

    if service.list_servers.body['servers'].none? { |s| s['name'] == attributes[:name] }
      service.create_server(
        attributes[:name],
        attributes[:image],
        attributes[:flavor],
        {
          'tenant_id'      => project.id,
          'security_group' => service.security_groups[0].id,
          'user_id'        => service.current_user['id']
        }
      )
    end

    service.servers.find { |s| s.name == attributes[:name] }
  end

  def create_volume(attributes = {})
    attrs = CloudObjectBuilder.attributes_for(:volume)
    attrs.merge!(attributes)

    service.create_volume(attrs.name, attrs.description, attrs.size)
  end

  def delete_instances_in_project(project)
    deleted_instances = []
    set_tenant project
    project_instances = instances.find_all{ |i| i.tenant_id == project.id }
    attached_volumes  = service.volumes.select{ |v| !v.attachments.empty? && v.attachments.none?(&:empty?) }

    # There seems to be a bug in OpenStack. Sometimes this fails,
    # sometimes this works just fine.
    sleeping(0.5).seconds.between_tries.failing_after(10).tries do
      service.set_tenant 'admin'
    end

    if project_instances
      project_instances.each do |instance|
        deleted_instances << { name: instance.name, id: instance.id }

        # Detach any attached volumes
        attachments = attached_volumes.select{ |v| v.attachments.any?{ |a| a['serverId'] == instance.id } }
        attachments.each do |attachment|
          service.detach_volume(instance.id, attachment.id)
          sleep(0.5)
        end

        service.delete_server(instance.id)
      end
    end

    deleted_instances
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

    sleeping(1).seconds.between_tries.failing_after(60).tries do
      volumes = service.volumes
      if desired_count > volumes.count
        (desired_count - volumes.count).times do
          create_volume
          sleep(0.5)
        end
      end

      attached_volumes     = volumes.select{ |v| v.attachments.any?{ |a| a['serverId'] == instance.id } }
      non_attached_volumes = volumes.select{ |v| v.attachments.first.empty? }
      if desired_count > attached_volumes.count
        (desired_count - attached_volumes.count).times do |i|
          service.attach_volume(non_attached_volumes[i].id, instance.id, '/dev/vdz')
          sleep(0.5)
        end
      elsif strict && desired_count < attached_volumes.count
        (attached_volumes.count - desired_count).times do |i|
          service.detach_volume(instance.id, attached_volumes[i].id)
          sleep(0.5)
        end
      end

      volumes.count
    end
  end

  def ensure_project_floating_ip_count(project, desired_count, instance=nil)
    service.set_tenant project

    keep_trying do
      addresses = service.addresses
      actual_count = addresses.count

      if desired_count > actual_count

        how_many = desired_count - actual_count
        how_many.times do |n|
          service.allocate_address
          sleep(0.5)
        end
        addresses.reload


      elsif desired_count < addresses.length

        while addresses.length > desired_count
          addresses.reload
          addresses[0].destroy rescue nil
        end

      end

      # Floating IPs should usually be associated to an instance
      if instance
        desired_count.times do |n|
          if addresses[n]
            service.associate_address(instance.id, addresses[n].ip)
            sleep(0.5)
          end
        end
      end

      addresses.reload
      addresses = addresses.select { |a| a.instance_id == instance.id } if instance
      if addresses.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "floating IPs. Current number of floating IPs is #{ addresses.length }."
      end

      if addresses.count == 1
        addresses.first
      elsif addresses.count > 1
        addresses
      end
    end
  end

  # Ensures that there are `desired_count` number of instances in the project
  # Set `strict` to false if you don't mind having more than `desired_count`
  # number of instances in the project.
  def ensure_active_instance_count(project, desired_count, strict = true)
    service.set_tenant project

    # This block will keep running until it stops raising an error, or until
    # the max number of tries is reached. In the last try, whatever error is
    # raised by the block is thrown.
    sleeping(1).seconds.between_tries.failing_after(30).tries do
      instances.reload

      non_active_instances  = instances.select{ |i| i.state !~ /^ACTIVE|ERROR$/}
      instances_with_errors = instances.select{ |i| i.state =~ /^ERROR$/}

      # Do pre-checks
      if non_active_instances.count > 0
        # Check if there are any suspended or paused instances,
        # and reactivate them
        non_active_instances.each do |instance|
          case instance.state
          when 'SUSPENDED'
            service.resume_server(instance.id)
          when 'PAUSED'
            service.unpause_server(instance.id)
          end
          sleep(0.5)
        end

        # Check if any/all of the instances above have successfully activated
        instances.reload
        active_instances = instances.select { |i| i.state == 'ACTIVE' }
        if active_instances.count < desired_count
          raise_ensure_active_instance_count_error "Some instances took too long to transition to a specific state.", desired_count
        end
      elsif instances_with_errors.count > 0
        # We have to remove instances that have errors because they also
        # occuppy slots in the quota, preventing us from firing up more
        # instances.
        instances_with_errors.each{ |i| i.destroy }
        raise_ensure_active_instance_count_error "Some instances that have errors took too long to delete.", desired_count
      end

      # At this point, we should be guaranteed that all instances are ACTIVE

      if desired_count > instances.count
        (desired_count - instances.count).times do
          create_instance_in_project(project)
          sleep(0.5)      # Don't send too many requests at once
        end
        raise_ensure_active_instance_count_error "The compute service doesn't seem to be responding to my 'launch instance' requests.", desired_count
      elsif strict && desired_count < instances.count
        (instances.count - desired_count).times do |i|
          instances[i].destroy
        end
        raise_ensure_active_instance_count_error "Some extra instances took to long to delete.", desired_count
      end
    end # sleeping(x).seconds.between_tries.failing_after(y).tries

    instances.count
  end

  # Ensures that there are `desired_count` number of instances in the project
  # Set `strict` to false if you don't mind having more than `desired_count`
  # number of instances in the project.
  def ensure_paused_instance_count(project, desired_count, strict = true)
    service.set_tenant project

    # This block will keep running until it stops raising an error, or until
    # the max number of tries is reached. In the last try, whatever error is
    # raised by the block is thrown.
    sleeping(1).seconds.between_tries.failing_after(60).tries do
      instances.reload

      paused_instances = instances.select{ |i| i.state =~ /^PAUSED$/ }

      if desired_count > paused_instances.count
        # Cannot pause without any active instances so we need to ensure active instance count
        active_instances = instances.select{ |i| i.state =~ /^ACTIVE$/ }
        if active_instances.count < desired_count - paused_instances.count
          ensure_active_instance_count(project, desired_count - paused_instances.count, false)

          # Reload list of active instances
          instances.reload
          active_instances = instances.select{ |i| i.state =~ /^ACTIVE$/ }
        end

        (desired_count - paused_instances.count).times do |i|
          service.pause_server(active_instances[i].id)
          sleep(0.5)      # Don't send too many requests at once
        end

        raise_ensure_paused_instance_count_error "Some instances took to long to pause.", desired_count
      elsif strict && desired_count < paused_instances.count
        (paused_instances.count - desired_count).times do |i|
          service.unpause_server(paused_instances[i].id)
          sleep(0.5)      # Don't send too many requests at once
        end

        raise_ensure_paused_instance_count_error "Some extra instances took to long to unpause.", desired_count
      end
    end # sleeping(x).seconds.between_tries.failing_after(y).tries

    instances.length
  end

  # Ensures that there are `desired_count` number of instances in the project
  # Set `strict` to false if you don't mind having more than `desired_count`
  # number of instances in the project.
  def ensure_suspended_instance_count(project, desired_count, strict = true)
    service.set_tenant project

    # This block will keep running until it stops raising an error, or until
    # the max number of tries is reached. In the last try, whatever error is
    # raised by the block is thrown.
    sleeping(1).seconds.between_tries.failing_after(60).tries do
      instances.reload

      suspended_instances = instances.select{ |i| i.state =~ /^SUSPENDED$/ }

      if desired_count > suspended_instances.count
        # Cannot suspend without any active instances so we need to ensure active instance count
        active_instances = instances.select{ |i| i.state =~ /^ACTIVE$/ }
        if active_instances.count < desired_count - suspended_instances.count
          ensure_active_instance_count(project, desired_count - suspended_instances.count, false)

          # Reload list of active instances
          instances.reload
          active_instances = instances.select{ |i| i.state =~ /^ACTIVE$/ }
        end

        (desired_count - suspended_instances.count).times do |i|
          service.suspend_server(active_instances[i].id)
          sleep(0.5)      # Don't send too many requests at once
        end

        raise_ensure_suspended_instance_count_error "Some instances took to long to suspend.", desired_count
      elsif strict && desired_count < suspended_instances.count
        (suspended_instances.count - desired_count).times do |i|
          service.resume_server(suspended_instances[i].id)
          sleep(0.5)      # Don't send too many requests at once
        end

        raise_ensure_suspended_instance_count_error "Some extra instances took to long to resume.", desired_count
      end
    end # sleeping(x).seconds.between_tries.failing_after(y).tries

    instances.length
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

  def ensure_security_group_rule(project, ip_protocol='tcp', from_port=2222, to_port=2222, cidr='0.0.0.0/0')
    service.set_tenant project
    security_group = service.security_groups.first
    parent_group_id = security_group.id

    # Ensure that there are no security group rule before adding anything
    security_group.rules.each do |r|
      service.delete_security_group_rule(r['id'])
    end

    service.create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr)
  rescue => e
    raise "#test{ JSON.parse(e.response.body)['badRequest']['message'] }"
  end

  def ensure_security_group_rule_exist(project, ip_protocol='tcp', from_port=2222, to_port=2222, cidr='0.0.0.0/0')
    service.set_tenant project
    security_group = service.security_groups.first
    parent_group_id = security_group.id

    # Ensure that there are no security group rule before adding anything
    security_group.rules.each do |r|
      service.delete_security_group_rule(r['id'])
    end

    service.create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr)

  rescue => e
    raise "#test{ JSON.parse(e.response.body)['badRequest']['message'] }"
  end

  def create_security_group(project, attributes)
    service.set_tenant project
    security_group = service.security_groups
    new_security_group = security_group.find_by_name(attributes[:name])
      if new_security_group
         #raise "Security Group #{attributes[:name]} is already exists."
         new_security_group.destroy
         security_group = security_group.new(attributes)
         security_group.save
         security_group
      else
         security_group = security_group.new(attributes)
         security_group.save
         security_group
      end
  end

  def delete_security_group(security_group)
    security_group.destroy
  end

  def ensure_security_group_exists(project, attributes)
    service.set_tenant project
    security_group = service.security_groups.find_by_name(attributes[:name]) rescue nil

    if security_group
      security_group.destroy
      new_security_group = create_security_group(project, attributes)
    else
      new_security_group = create_security_group(project, attributes)
    end
    security_group = new_security_group
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
    security_group = service.security_groups
    if security_group = security_groups.find_by_name(attributes[:name])
      delete_security_group(security_group)
    end
  end

  def find_security_group_by_name(project, name)
    service.set_tenant project
    security_group = service.security_groups
    security_group.find_by_name(name)
    security_group
  end

  def set_tenant(project, reload = true)
    if @current_project != project
      @current_project = project
      service.set_tenant(project)
    end
    if reload
      addresses.reload
      flavors.reload
      instances.reload
    end
  end

  def create_security_group(project, attributes)
    service.set_tenant project
    security_group = service.security_groups
    new_security_group = security_group.find_by_name(attributes[:name])
      if new_security_group
         #raise "Security Group #{attributes[:name]} is already exists."
         new_security_group.destroy
         security_group = security_group.new(attributes)
         security_group.save
         security_group
      else
         security_group = security_group.new(attributes)
         security_group.save
         security_group
      end
  end

  def delete_security_group(security_group)
    security_group.destroy
  end

  def ensure_security_group_exists(project, attributes)
    service.set_tenant project
    security_group = service.security_groups
    find_security_group = security_group.find_by_name(attributes[:name]) rescue nil
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
    security_group = service.security_groups
    if security_group = security_groups.find_by_name(attributes[:name])
      delete_security_group(security_group)
    end
  end

  def find_instance_by_name(project, name)
    service.set_tenant project
    instance = service.servers.find_by_name(name)
    service.set_tenant 'admin'
    instance
  end

  def find_security_group_by_name(project, name)
    service.set_tenant project
    security_group = service.security_groups
    security_group.find_by_name(name)
    security_group
  end

  def get_project_instances(project)
    service.set_tenant project
    instances.reload
    i = instances
    service.set_tenant 'admin'
    i
  end

  def set_tenant(project, reload = true)
    if @current_project != project
      @current_project = project
      service.set_tenant(project)
    end
    if reload
      addresses.reload
      flavors.reload
      instances.reload
    end
  end

  private

  def check_building_project_instance_progress(instances, expected_count)
    keep_trying(wait: 5.seconds) do
      count = instances.count { |i| i.state == 'ACTIVE' }
      if count < expected_count
        raise "Instances are taking too long to build! " +
              "Expected #{ expected_count } building instances to be active."
      end
    end
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

end
