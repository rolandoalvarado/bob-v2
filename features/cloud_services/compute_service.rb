require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :instances

  def initialize
    initialize_service Compute
    @instances = service.servers
  end

  def create_floating_ip_in_project(project, instance=nil)
    service.set_tenant project
    service.allocate_address

    address = service.addresses.last
    raise "Floating IP can't be found!" unless address

    if instance
      begin
        service.associate_address(instance.id, address.ip)
      rescue
        raise "Cannot associate floating IP #{ address.ip } to instance #{ instance.id }."
      end
    end

    address
  end

  def create_instance_in_project(project)
    service.create_server(
      Faker::Name.name,
      service.images[0].id,
      service.flavors[0].id,
      {
        'tenant_id'      => project.id,
        'key_name'       => service.key_pairs[0].name,
        'security_group' => service.security_groups[0].id,
        'user_id'        => service.current_user['id']
      }
    )
  rescue
    raise "Couldn't initialize instance in #{ project.name }"
  end

  def ensure_project_floating_ip_count(project, desired_count)
    service.set_tenant project
    addresses = service.addresses
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

  def ensure_project_instance_count(project, desired_count)
    service.set_tenant project
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

  def project_instance(project)
    service.set_tenant project

    instance = service.servers.first
    if instance.nil? or instance.id.empty?
      raise "Instance can't be found!"
    end

    instance
  end

end
