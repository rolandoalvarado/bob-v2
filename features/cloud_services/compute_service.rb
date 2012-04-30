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
    actual_count = instances.count

    if desired_count > actual_count
      how_many = desired_count - actual_count
      how_many.times do |n|
        create_instance_in_project(project)
      end
      instances.reload
    elsif desired_count < instances.length
      # Reduce number of instances
      raise "Write code to reduce instances in project"
    end

    instances.reload
    instances.length
  end

end