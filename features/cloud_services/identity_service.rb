# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'

# This is a wrapper for Fog::Identity. We're wrapping it to ensure that
# we only have one instance of it in memory at any point in time.

class IdentityService
  include Singleton
  include CloudConfiguration

  attr_reader :test_tenant, :users, :tenants, :roles

  def initialize
    service  = Fog::Identity.new(ConfigFile.cloud_credentials)
    @users   = service.users
    @tenants = service.tenants
    @roles   = service.roles

    test_tenant_name = "mCloud Features"
    @test_tenant = find_test_tenant(test_tenant_name) || create_test_tenant(test_tenant_name)
  end

  private

  def service
    @service
  end

  def service=(value)
    @service = value
  end

  def create_test_tenant(name)
    attributes = CloudObjectBuilder.attributes_for(:tenant, :name => name)
    tenant = tenants.new(attributes)
    tenant.save
    tenant
  end

  def find_test_tenant(name)
    tenants.find_by_name(name)
  end
end