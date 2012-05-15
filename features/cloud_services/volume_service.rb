require_relative 'base_cloud_service'

class VolumeService < BaseCloudService

  attr_reader :volumes, :current_project

  def initialize
    initialize_service Volume
    @volumes = service.list_volumes.body['volumes']
  end

  def assert_volume_count(project, desired_count)
    set_tenant(project)
    @volumes = service.list_volumes.body['volumes']

    if @volumes.count != desired_count
      raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
            "volumes. Current number of volumes is #{ @volumes.length }."
    end
  end

  def create_volume(attributes = {})
    attrs = CloudObjectBuilder.attributes_for(:volume)
    attrs.merge!(attributes)

    service.create_volume(attrs.name, attrs.description, attrs.size)
  end

  def delete_volumes_in_project(project)
    deleted_volumes = []
    set_tenant project
    reload_volumes

    volumes.each do |volume|
      deleted_volumes << { name: volume['display_name'], id: volume['id'] }
      service.delete_volume(volume['id'])
    end

    set_tenant 'admin'
    reload_volumes
    deleted_volumes
  end

  def ensure_volume_count(project, desired_count)
    set_tenant(project)
    @volumes = service.list_volumes.body['volumes']
    try_fixing_volume_count(project, desired_count)
    true
  end

  def reload_volumes
    @volumes = service.list_volumes.body['volumes']
  end

private

  def try_fixing_volume_count(project, desired_count)
    sleeping(2).seconds.between_tries.failing_after(10).tries do
      difference = (@volumes.count - desired_count).abs

      if(@volumes.count > desired_count)
        difference.times do
          service.delete_volume(@volumes.pop['id'])
        end
      elsif(@volumes.count < desired_count)
        difference.times do
          create_volume
        end
      end

      assert_volume_count(project, desired_count)
    end
  end

  def set_tenant(project)
    if(@current_project != project)
      @current_project = project
      service.set_tenant(project)
    end
  end

end
