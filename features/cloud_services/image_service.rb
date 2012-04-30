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

end