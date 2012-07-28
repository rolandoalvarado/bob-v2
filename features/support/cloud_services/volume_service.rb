require_relative 'base_cloud_service'

class VolumeService < BaseCloudService

  attr_reader :volumes, :snapshots, :current_project

  def initialize
    initialize_service Volume
    @volumes   = service.list_volumes.body['volumes']
    @snapshots = service.list_snapshots.body['snapshots']
  end

  def assert_volume_count(project, desired_count)
    set_tenant(project)

    if @volumes.count != desired_count
      raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
        "volumes. Current number of volumes is #{ volumes.length }."
    end
  end

  def create_volume(attributes = {})
    attrs = CloudObjectBuilder.attributes_for(:volume)
    attrs.merge!(attributes)

    service.create_volume(attrs.name, attrs.description, attrs.size)
  end

  def create_volume_snapshot(volume, attributes = {})
    raise "Volume couldn't be found!" unless volume

    attrs = CloudObjectBuilder.attributes_for(:snapshot)
    attrs.merge!(attributes)

    service.create_volume_snapshot(volume['id'], attrs.name, attrs.description)
  end

  def create_volume_in_project(project, attributes)
    attrs = CloudObjectBuilder.attributes_for(:volume, attributes)
    set_tenant project
    volume = @volumes.find { |v| v['display_name'] == attrs.name }

    unless volume
      # Create volume if it does not exist yet
      service.create_volume(attrs.name, attrs.description, attrs.size)
    else
      # Detach volumes from all instances
      attachments = volume['attachments'].select { |a| !a.empty? }
      attachments.each do |attachment|
        # Volume service does not have its own detach volume function
        compute_service = ComputeService.session.service
        compute_service.detach_volume(attachment['server_id'], attachment['id'])
        sleep(ConfigFile.wait_short)
      end

      sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
        reload_volumes
        volume = @volumes.find { |v| v['display_name'] == attrs.name }
        attachment_count = volume['attachments'].count { |a| !a.empty? }
        raise "Couldn't detach volume #{ volume['display_name'] }!" unless attachment_count == 0
      end

      # If volume is in error state, recreate volume
      if volume['status'] == 'error_deleting'
        service.delete_volume(volume['id'])
        sleep(ConfigFile.wait_long) # Avoid delete and create at the same time just to be safe :)
        service.create_volume(attrs.name, attrs.description, attrs.size)
      end
    end

    # Check until volume status is available
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      reload_volumes
      volume = @volumes.find { |v| v['display_name'] == attrs.name }
      unless volume['status'] == 'available'
        raise "Volume #{ volume['display_name'] } took too long to become available! " +
              "Volume is currently #{ volume['status'] }."
      else
        return volume
      end
    end
  end

  def delete_volume_in_project(project, volume)
    set_tenant project, false
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      reload_volumes
      volume = volumes.find { |v| v['id'] == volume['id'] }
      if volume['status'] !~ /available|error/
        raise "Volume #{ volume['display_name'] } took too long to be ready for deletion. " +
              "Volume is currently #{ volume['status'] }."
      end
    end
    service.delete_volume(volume['id'])
  end

  def delete_volumes_in_project(project)
    deleted_volumes = []
    set_tenant project

    volumes.each do |volume|
      deleted_volumes << { name: volume['display_name'], id: volume['id'] }
      delete_volume_in_project(project, volume)
    end

    set_tenant 'admin'
    deleted_volumes
  end

  def delete_volume_snapshots_in_project(project)
    deleted_snapshots = []
    set_tenant project

    snapshots.each do |snapshot|
      deleted_snapshots << { name: snapshot['display_name'], id: snapshot['id'] }
      service.delete_snapshot snapshot['id']
    end

    set_tenant 'admin'
    deleted_snapshots
  end

  def ensure_volume_count(project, desired_count)
    set_tenant project
    try_fixing_volume_count(project, desired_count)
    reload_volumes
    volumes.count
  end

  def ensure_volume_snapshot_count(project, volume, desired_count, strict = true)
    set_tenant(project, false)

    sleeping(5).seconds.between_tries.failing_after(10).tries do
      reload_snapshots

      count_difference = (snapshots.count - desired_count).abs
      if snapshots.count < desired_count
        count_difference.times do
          create_volume_snapshot(volume)
          sleep(0.5)
        end
      elsif strict && snapshots.count > desired_count
        count_difference.times do |i|
          service.delete_snapshot(snapshots[i]['id'])
          sleep(0.5)
        end
      end

      reload_snapshots
      if snapshots.count != desired_count
        raise "Couldn't ensure that #{ project.name } has #{ desired_count } " +
          "volume snapshots. Current number of volume snapshots is #{ snapshots.count }."
      end

      return snapshots.count
    end
  end

  def find_volume_by_name(project, name)
    service.set_tenant project
    service.list_volumes.body['volumes'].find { |v| v['display_name'] == name }
  end

  def reload_snapshots
    @snapshots = service.list_snapshots.body['snapshots']
  end

  def reload_volumes
    @volumes = service.list_volumes.body['volumes']
  end

  def set_tenant(project, reload = true)
    if @current_project != project
      @current_project = project
      service.set_tenant(project)
    end
    if reload
      reload_volumes
      reload_snapshots
    end
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
end
