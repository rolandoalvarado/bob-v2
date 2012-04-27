# BASE CLASS to be inherited by other classes in this directory

# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'

class BaseCloudService
  include Singleton
  include CloudConfiguration
  include Fog                 # Make Fog classes directly available to child classes

  #============================
  # CLASS METHODS
  #============================

  # Alias for Singleton::instance since 'instance' has a special
  # meaning in the context of mCloud/OpenStack
  def self.session
    instance
  end

  #============================
  # INSTANCE METHODS
  #============================

  attr_reader :service

  def initialize
    raise "#{ self.class } should define an initialize method"
  end

  protected

  def initialize_service(service_type)
    @service = service_type.new(ConfigFile.cloud_credentials)
  end
end