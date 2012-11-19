# BASE CLASS to be inherited by other classes in this directory

# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'
require 'anticipate'
require_relative '../gems'

class BaseCloudService
  include Anticipate
  include Singleton
  include CloudConfiguration
  include Fog                 # Make Fog classes directly available to subclasses

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

  attr_reader :service, :current_user

  def initialize
    raise "#{ self.class } should define an initialize method"
  end

  def set_credentials(username=nil, password=nil)
    credentials = ConfigFile.cloud_credentials
    unless username.blank? || password.blank?
      credentials.merge!(:openstack_username => username, :openstack_api_key  => password)
      credentials.delete(:openstack_tenant)
    end

    @service = @service_type.new(credentials)
    @current_user = @service.current_user
  end

  def reset_credentials
    set_credentials # without parameters
  end

  def set_tenant(project, reload = true)
    if @current_project != project || reload
      @current_project = project
      service.set_tenant(project)
    end
    load_resources(reload)
  end

  def set_tenant!(project)
    set_tenant(project, true)
  end


  protected

  def initialize_service(service_type)
    @service_type = service_type
    set_credentials
  end

end
