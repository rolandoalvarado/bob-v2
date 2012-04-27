require_relative 'base_cloud_service'

class IdentityService < BaseCloudService

  attr_reader :test_tenant, :users, :tenants, :roles

  def initialize
    @service  = Identity.new(ConfigFile.cloud_credentials)
    @users   = service.users
    @tenants = service.tenants
    @roles   = service.roles

    test_tenant_name = 'admin'
    @test_tenant = find_test_tenant(test_tenant_name) || create_test_tenant(test_tenant_name)

    @roles = {}
    @roles[:cloud_admin] = service.roles.find_by_name('admin')
  end

  def create_tenant(attributes)
    tenant = tenants.new(attributes)
    tenant.save
    tenant
  end

  def create_user(attributes)
    attributes[:tenant_id] = test_tenant.id
    user = users.new(attributes)
    user.save
    test_tenant.add_user(user.id, @roles[:cloud_admin].id)
    user
  end

  def ensure_tenant_exists(attributes)
    tenant = tenants.find_by_name(attributes[:name])
    if tenant
      tenant.update(attributes)
    else
      tenant = create_tenant(attributes)
    end
    tenant
  end

  def ensure_user_exists(attributes)
    user = users.find_by_name(attributes[:name])
    if user
      user.update(attributes)
    else
      user = create_user(attributes)
    end
    user
  end

  #================================================
  # COMPUTE SERVICE-RELATED METHODS
  # Convenience methods to make the DSL consistent
  # with the Compute Service's language
  #================================================

  def ensure_project_exists(attributes)
    ensure_tenant_exists(attributes)
  end

  def projects
    tenants
  end

  #================================================
  # PRIVATE METHODS
  #================================================

  private

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