require_relative 'base_cloud_service'

class IdentityService < BaseCloudService

  attr_reader :test_tenant, :users, :tenants, :roles

  def initialize
    initialize_service Identity
    @users   = service.users
    @tenants = service.tenants
    @roles   = service.roles

    test_tenant_name = 'admin'
    @test_tenant = find_test_tenant(test_tenant_name) || create_test_tenant(test_tenant_name)
  end

  def create_tenant(attributes)
    tenant = tenants.new(attributes)
    tenant.save
    tenant
  end

  def delete_tenant(attributes)
    tenant = find_test_tenant(attributes[:name])
    if(tenant == nil or tenant.id == nil )
      return
    end
    users = tenant.users
    users.each do |user|
      revoke_all_user_roles(user, tenant)
    end

    sleeping(1).seconds.between_tries.failing_after(20).tries do
      tenant.destroy
    end
  end

  def create_user(attributes)
    attributes[:tenant_id] = test_tenant.id
    user = users.new(attributes)
    user.save
    admin_role = roles.find_by_name(RoleNameDictionary.db_name('System Admin'))
    test_tenant.grant_user_role(user.id, admin_role.id)
    user
  end

  def ensure_tenant_exists(attributes)
    attributes        = CloudObjectBuilder.attributes_for(:tenant, attributes)
    attributes[:name] = Unique.name(attributes[:name], 25)

    tenant = tenants.find_by_name(attributes[:name])
    if tenant
      tenant.update(attributes)
    else
      tenant = create_tenant(attributes)
    end

    # Make ConfigFile.admin_username an admin of the tenant. This is so that we
    # can manipulate it as needed. Turns out the 'admin' role in Keystone is
    # not really a global role
    admin_user  = users.find_by_name(ConfigFile.admin_username)
    raise "The user #{ ConfigFile.admin_username } could not be found!" unless admin_user

    manager_role  = roles.find_by_name(RoleNameDictionary.db_name('Project Manager'))
    raise "The role #{ RoleNameDictionary.db_name('Project Manager') } could not be found!" unless manager_role

    tenant.grant_user_role(admin_user.id, manager_role.id)

    tenant
  end

  def ensure_user_exists(attributes)
    user = users.find_by_name(attributes[:name])
    if user
      user.update(attributes)
    else
      user = create_user(attributes)
    end
    user.password = attributes[:password]
    user
  end

  def revoke_all_user_roles(user, tenant)
    user.roles(tenant.id).each do |role|
      tenant.revoke_user_role(user.id, role['id'])
    end
  end

  #================================================
  # COMPUTE SERVICE-RELATED METHODS
  # Convenience methods to make the DSL consistent
  # with the Compute Service's language
  #================================================

  def ensure_project_exists(attributes)
    ensure_tenant_exists(attributes)
  end

  def add_user_to_project(user_id, project_id, role_id)
    pending
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
