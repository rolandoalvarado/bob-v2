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

end
