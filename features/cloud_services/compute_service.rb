require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  def initialize
    service  = Compute.new(ConfigFile.cloud_credentials)
  end

end