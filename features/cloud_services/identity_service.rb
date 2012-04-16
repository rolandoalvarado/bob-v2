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

    test_tenant_name = 'admin'
    @test_tenant = find_test_tenant(test_tenant_name) || create_test_tenant(test_tenant_name)

    @roles = {}
    @roles[:cloud_admin] = service.roles.find_by_name('admin')
  end

  def create_user(user_attrs)
    user_attrs[:tenant_id] = test_tenant.id
    user = users.new(user_attrs)
    user.save
    test_tenant.add_user(user.id, @roles[:cloud_admin].id)
  end

  def ensure_user_exists(user_attrs)
    user = users.find_by_name(user_attrs[:name])
    if user
      user.update(user_attrs)
    else
      create_user(user_attrs)
    end
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