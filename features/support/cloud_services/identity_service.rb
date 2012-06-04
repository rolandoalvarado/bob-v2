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


  #=================================================
  # CATCH METHOD CALLS THAT HAVE 'project' in them
  # Since 'project' is just an alias for 'tenant',
  # let's automatically translate such method calls.
  #=================================================

  def method_missing(name, *args, &block)
    xlated_name = name.to_s.gsub('project', 'tenant')
    if name =~ /project/ && respond_to?(xlated_name)
      send xlated_name, *args, &block
    else
      super name, *args, &block
    end
  end

  def respond_to_missing?(name)
    respond_to? name.to_s.gsub('project', 'tenant')
  end

  #=================================================

  def create_tenant(attributes)
    tenant = tenants.new(attributes)
    tenant.save
    tenant
  end

  def delete_tenant(tenant)
    users = tenant.users
    users.reload.each do |user|
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

  def delete_user(user)
    tenants.reload.each do |tenant|
      revoke_all_user_roles(user, tenant)
    end

    # Sometimes, OpenStack takes a while to complete the deletion
    # of all foreign key constraints. So we have to keep trying
    sleeping(1).seconds.between_tries.failing_after(15).tries do
      user.destroy
    end
  end

  # System Admin    = 'admin' in admin tenant, 'Member' in all tenants
  # Project Manager = 'admin' in admin tenant, 'Member' in the tenant
  # Member          = 'Member' in the tenant
  def ensure_tenant_role(user, tenant, role_name)
    valid_roles = ['Project Manager', 'Member', '(None)']

    unless valid_roles.include?(role_name)
      raise "Unknown role '#{ role_name }'. Valid roles are #{ valid_roles.join(',') }"
    end

    if role_name == 'Project Manager'
      admin_role   = roles.find_by_name('admin')
      admin_tenant = tenants.find_by_name('admin')
      admin_tenant.grant_user_role(user.id, admin_role.id)
    end

    if ['Project Manager', 'Member'].include?(role_name)
      member_role = roles.find_by_name('Member')
      tenant.grant_user_role(user.id, member_role.id)
    end
  end

  def ensure_tenant_does_not_exist(attributes)
    if tenant = tenants.find_by_name(attributes[:name])
      ComputeService.session.delete_instances_in_project(tenant)
      VolumeService.session.delete_volumes_in_project(tenant)
      delete_tenant(tenant)
    end
  end

  def ensure_tenant_exists(attributes)
    attributes        = CloudObjectBuilder.attributes_for(:tenant, attributes)
    attributes[:name] = Unique.project_name(attributes[:name])

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

    # This is just a work around for openstack bug:
    # - https://bugs.launchpad.net/horizon/+bug/967882
    #
    # The bug is the wrong scoping of certain project resources on a
    # user using an admin role. The right role should be a project manager role.
    member_role   = roles.find_by_name(RoleNameDictionary.db_name('Member'))
    raise "The role #{ RoleNameDictionary.db_name('Member') } could not be found!" unless member_role

    # Make sure user has no project manager role in project
    response = service.list_roles_for_user_on_tenant(tenant.id, admin_user.id)
    manager_role = response.body['roles'].find {|r| r['name'] == RoleNameDictionary.db_name('Project Manager') }
    tenant.revoke_user_role(admin_user.id, manager_role['id']) if manager_role
    tenant.grant_user_role(admin_user.id, member_role.id)

    tenant
  end

  def ensure_user_does_not_exist(attributes)
    if user = find_user_by_name(attributes[:name])
      delete_user(user)
    end
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

  def find_user_by_name(name)
    users.reload.find_by_name(name)
  end

  def find_tenant_by_name(name)
    tenants.find_by_name(name)
  end

  def revoke_all_user_roles(user, tenant)
    user.roles(tenant.id).each do |role|
      tenant.revoke_user_role(user.id, role['id'])
    end

    sleeping(1).seconds.between_tries.failing_after(15).tries do
      raise "Roles for user #{ user.name } on tenant #{ tenant.name } took too long to revoke!" if user.roles(tenant.id).length > 0
    end
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
