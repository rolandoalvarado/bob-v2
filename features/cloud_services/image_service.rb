# This is a wrapper for Fog::Compute. We're wrapping it to ensure that
# we only have one instance of it in memory at any point in time.
require_relative 'base_cloud_service'

class ImageService < BaseCloudService

  attr_reader :images

  def initialize
    service = Image.new(ConfigFile.cloud_credentials)
    @images = service.images
  end

end