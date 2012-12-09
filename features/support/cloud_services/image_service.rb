require_relative 'base_cloud_service'

class ImageService < BaseCloudService

  attr_reader :images

  def initialize
    initialize_service Image
    load_resources
  end

  def load_resources(reload = false)
    if reload
      @images = service.images
    else
      @images ||= service.images
    end
  end

  def create_image(attributes = {})
    attrs = CloudObjectBuilder.attributes_for(:image, attributes)
    image = @images.reload.find { |i| i.name == attrs.name }
    unless image
      begin
        service.create_image(attributes)
        sleep(ConfigFile.wait_long)
        image = @images.reload.find { |i| i.name == attrs.name }
      rescue => e
        raise "Couldn't initialize image #{ attrs.name }. " +
              "The error returned was: #{ e.inspect }"
      end
    end
    return image
  end

  def delete_image(image)
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      image = service.images.reload.find { |i| i.id == image.id }
      if image.status == 'saving'
        raise "Image #{ image.name } took too long to be ready for deletion. " +
              "It is currently #{ image.status }."
      end
    end

    compute_service = ComputeService.session
    attached_instances = compute_service.service.servers.select { |i| i.image == image }
    attached_instances.each do |instance|
      compute_service.delete_instance_in_project(compute_service.current_tenant)
      sleep(ConfigFile.wait_short)
    end

    service.delete_image(image.id)
  end

  def ensure_image_does_not_exist(project, attributes)
    compute_service = ComputeService.session
    compute_service.get_nova_images(project).each do |snapshot|
      compute_service.delete_snapshot_in_project(project, snapshot['id'])
      sleep(ConfigFile.wait_long)
    end
  end

  def get_public_images
    images.public
  end

  def get_default_image
    default_images = CloudConfiguration::ConfigFile.cleanup_exemptions[:images]
    images.public.select { |i| default_images.include?(i.name) }
  end

  def get_bootable_images
    #images.public.select {|i| i.disk_format !~ /^a[rk]i$/ && i.status == 'active' && i.properties.empty?}
    images.public.select {|i| i.disk_format !~ /^a[rk]i$/ && i.status == 'active' }
  end

  def get_instance_snapshots # Get Images with snapshot image_type.
    service.images.all.select { |i| i.disk_format !~ /^a[rk]i$/ && i.properties['image_type'] == 'snapshot' }
  end

  def get_glance_images
    default_images = CloudConfiguration::ConfigFile.cleanup_exemptions[:images]
    service.images.all.select { |i| !default_images.include?(i.name) }
  end

  def delete_images(project)
    deleted_images = []

    get_glance_images.each do |deleted_image|
      deleted_images << { name: deleted_image.name, id: deleted_image.id }
      delete_image(deleted_image)
    end

    deleted_images
  end

end
