require_relative 'base_cloud_service'

class ComputeService < BaseCloudService

  def initialize
    initialize_service Compute
  end
  end

end