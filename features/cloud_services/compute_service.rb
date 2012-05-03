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
      so_far = 0

      # Always use the 'each' iterator in this case because it takes a while
      # for an instance to be removed from the array.
      instances.each do |instance|
        instance.destroy
        so_far += 1
        break if so_far == (instances.length - desired_count)
      end
    end

    sleeping(0.1).seconds.between_tries.failing_after(20).tries do
      instances.reload

      if instances.length != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
              "instances. Current number of instances is #{ instances.length }."
      end
    end

    instances.length
  end

end