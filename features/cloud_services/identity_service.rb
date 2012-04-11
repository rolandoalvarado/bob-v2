# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'
require File.expand_path('../user_methods.rb', __FILE__)
require File.expand_path('../tenant_methods.rb', __FILE__)

class IdentityService
  include Singleton
  include Configuration
  include UserMethods
  include TenantMethods

  def initialize
    @service = Fog::Identity.new(Configuration.cloud_credentials)
  end
end