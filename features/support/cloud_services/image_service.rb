require_relative 'base_cloud_service'

class ImageService < BaseCloudService

  attr_reader :images

  def initialize
    initialize_service Image
    @images = service.images
  end

  def get_public_images
    images.public
  end

  def get_bootable_images
    images.public.select {|i| i.disk_format !~ /^a[rk]i$/ && i.status == 'active'}
  end
  
  def get_instance_snapshots # Get Images with snapshot image_type.
    images.public.select {|i| i.disk_format !~ /^a[rk]i$/ && i.status == 'active' && i.properties['image_type'] == 'snapshot'}
  end
  
  def delete_instance_snapshots(project) # Delete Instance Snapshots
    deleted_snapshots = []
              
    get_instance_snapshots.each do |snapshot|
      deleted_snapshots << { name: snapshot.name, id: snapshot.id }
      ComputeService.session.delete_snapshot_in_project(project, snapshot.id)
    end

    deleted_snapshots
  end
   
end
