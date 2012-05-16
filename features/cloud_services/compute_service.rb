require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :addresses, :instances

  def initialize
    initialize_service Compute
    @addresses = service.addresses
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

    if project_instances = instances.find_all{ |i| i.tenant_id == project.id }
      project_instances.each do |instance|
        deleted_instances << { name: instance.name, id: instance.id }
        service.delete_server(instance.id)
      end
    end

    service.set_tenant 'admin'
    deleted_instances
  end


  def ensure_project_floating_ip_count(project, desired_count)
    service.set_tenant project
    keep_trying do
      addresses.reload
      actual_count = addresses.count

      if desired_count > actual_count

        how_many = desired_count - actual_count
        how_many.times do |n|
          service.allocate_address
        end
        addresses.reload

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

  def ensure_project_instance_count(project, desired_count)
    service.set_tenant project
    keep_trying do
      instances.reload
      actual_count = instances.count

      if desired_count > actual_count

        how_many = desired_count - actual_count
        how_many.times do |n|
          create_instance_in_project(project)
        end
        instances.reload

      elsif desired_count < instances.length

        while instances.length > desired_count
          instances.reload
          begin
            instances[0].destroy
          rescue
          end
        end

      end

      if instances.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "instances. Current number of instances is #{ instances.length }."
      end

      instances.length
    end
  end

  def ensure_active_project_instance_count(project, desired_count)
    service.set_tenant project
    keep_trying do
      instances.reload

      active_instances      = instances.select { |i| i.state == 'ACTIVE' }
      building_instances    = instances.select { |i| i.state == 'BUILDING' }
      actual_active_count   = active_instances.count
      actual_building_count = building_instances.count

      if desired_count > actual_active_count

        if actual_building_count > 0
          expected_finished_count = desired_count - (actual_active_count - actual_building_count).abs
          check_building_project_instance_progress(building_instances, expected_finished_count)
        else
          how_many = desired_count - actual_active_count
          how_many.times do |n|
            create_instance_in_project(project)
          end
          instances.reload
        end

      elsif desired_count < actual_active_count

        while actual_active_count > desired_count
          instances.reload
          active_instances = instances.select { |i| i.state == 'ACTIVE' }

          active_instances[0].destroy rescue nil
        end

      end

      active_instances = instances.select { |i| i.state == 'ACTIVE' }
      if active_instances.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "active instances. Current number of active instances is " +
              "#{ active_instances.length }."
      end

      active_instances.length
    end
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

      instance
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

end
