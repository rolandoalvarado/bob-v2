require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  attr_reader :instances

  def initialize
    initialize_service Compute
    @instances = service.servers
  end

  def create_instance_in_project(project)
    service.create_server(
      Faker.Name.name,
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

end