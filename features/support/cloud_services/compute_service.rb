require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :addresses, :flavors, :instances

  def initialize
    initialize_service Compute
    @addresses = service.addresses
    @flavors   = service.flavors
    @instances = service.servers
  end

  def create_instance_in_project(project, attributes={})
    attributes[:name]   ||= Faker::Name.name
    attributes[:image]  ||= service.images[0].id
    attributes[:flavor] ||= service.flavors[0].id

    service.create_server(
      attributes[:name],
      attributes[:image],
      attributes[:flavor],
      {
        'tenant_id'      => project.id,
        'key_name'       => service.key_pairs[0].name,
        'security_group' => service.security_groups[0].id,
        'user_id'        => service.current_user['id']
      }
    )

    service.servers.find { |s| s.name == attributes[:name] }
  rescue
    raise "Couldn't initialize instance in #{ project.name }"
  end

  def delete_instances_in_project(project)
    deleted_instances = []
    service.set_tenant project
    instances.reload
    project_instances = instances.find_all{ |i| i.tenant_id == project.id }

    # There seems to be a bug in OpenStack. Sometimes this fails,
    # sometimes this works just fine.
    sleeping(0.5).seconds.between_tries.failing_after(10).tries do
      service.set_tenant 'admin'
    end

    if project_instances
      project_instances.each do |instance|
        deleted_instances << { name: instance.name, id: instance.id }
        service.delete_server(instance.id)
      end
    end

    deleted_instances
  end

  def release_addresses_from_project(project)
    released_addresses = []
    service.set_tenant project
    addresses.reload

    addresses.each do |address|
      address_attributes = { ip: address.ip, id: address.id }
      unless address.instance_id.blank?
        address_attributes.merge!( instance_id: address.instance_id )
        service.disassociate_address(address.instance_id, address.ip)
      end

      service.release_address(address.id)
      released_addresses << address_attributes
    end

    released_addresses
  end

  def ensure_project_floating_ip_count(project, desired_count, instance=nil)
    service.set_tenant project
    keep_trying do
      addresses.reload
      actual_count = addresses.count

      if desired_count > actual_count

        how_many = desired_count - actual_count
        how_many.times do |n|
          service.allocate_address
          sleep(0.5)
        end
        addresses.reload

        # Floating IPs should usually be associated to an instance
        if instance
          how_many.times do |n|
            service.associate_address(instance.id, addresses[n].id)
            sleep(0.5)
          end
          addresses.reload
        end

      elsif desired_count < addresses.length

        while addresses.length > desired_count
          addresses.reload
          addresses[0].destroy rescue nil
        end

      end

      if addresses.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "floating IPs. Current number of floating IPs is #{ addresses.length }."
      end

      addresses.length
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
    sleeping(1).seconds.between_tries.failing_after(60).tries do
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

    instances.length
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
    raise "#{ JSON.parse(e.response.body)['badRequest']['message'] }"
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