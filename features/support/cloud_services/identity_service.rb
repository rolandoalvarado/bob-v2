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

  def create_tenant(attributes = {})
    attributes = CloudObjectBuilder.attributes_for(:tenant, attributes)
    tenant = tenants.new(attributes)
    tenant.save
    tenant
  end

  def delete_tenant(tenant)
    tenant_name = tenant.name
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      tenant = @tenants.reload.find_by_name(tenant_name)
      begin
        tenant.destroy
      rescue
        raise "Tenant #{ tenant_name } took too long to delete!"
      end
    end
  end

  def create_user(attributes)
    tenants.reload
    project = tenants.find_by_id(attributes[:project_id]) rescue test_tenant
    attributes[:tenant_id] = project.id
    user = users.new(attributes)
    user.save
    member_role = roles.find_by_name(RoleNameDictionary.db_name('Member'))
    project.grant_user_role(user.id, member_role.id)
    user
  end

  def delete_user(user)
    tenants.reload.each do |tenant|
      revoke_all_user_roles(user, tenant)
    end

    # Sometimes, OpenStack takes a while to complete the deletion
    # of all foreign key constraints. So we have to keep trying
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      user.destroy
    end
  end

  def ensure_project_count(desired_count)
    @tenants.reload
    return if @tenants.count == desired_count
    delta_count = (@tenants.count - desired_count).abs

    if @tenants.count > desired_count
      delta_count.times do
        tenant = @tenants.pop
        tenant.destroy
        sleep(ConfigFile.wait_short)
      end
    elsif @tenants.count < desired_count
      delta_count.times do
        create_tenant
        sleep(ConfigFile.wait_short)
      end
    end

    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
      @tenants.reload
      if @tenants.count != desired_count
        raise "Could not ensure #{ desired_count } projects exist in the system! " +
              "Current count is #{ @tenants.count }."
      end
    end
  end

  # System Admin    = 'admin' in admin tenant, 'Member' in all tenants
  # Project Manager = 'admin' in admin tenant, 'Member' in the tenant
  # Member          = 'Member' in the tenant
  def ensure_tenant_role(user, tenant, role_name)
    valid_roles = ['System Admin', 'Admin', 'Project Manager', 'Member', '(None)']

    unless valid_roles.include?(role_name)
      raise "Unknown role '#{ role_name }'. Valid roles are #{ valid_roles.join(',') }"
    end
    
    revoke_all_user_roles(user, tenant) # It's for (None)
    
    if ['System Admin', 'Admin', 'Project Manager', 'Member'].include?(role_name)
      admin_tenant = tenants.find_by_name('admin')
      member_role = roles.find_by_name('Member')
      user.update_tenant(tenant.id)
      tenant.grant_user_role(user.id, member_role.id)
      revoke_all_user_roles(user, admin_tenant)
      if ['System Admin', 'Admin','Project Manager'].include?(role_name)
        admin_role   = roles.find_by_name('admin')
        admin_tenant.grant_user_role(user.id, admin_role.id)
      end
    end

  end
  
  def ensure_user_role_is_admin(user, role_name)
    tenants.reload
    valid_roles = ['System Admin', 'Admin']

    unless valid_roles.include?(role_name)
      raise "Unknown role '#{ role_name }'. Valid roles are #{ valid_roles.join(',') }"
    end
    
    if ['System Admin', 'Admin'].include?(role_name)
      admin_tenant = tenants.find{|t| t.name == 'admin'}
      revoke_all_user_roles(user, admin_tenant)
      
      admin_role   = roles.find_by_name('admin')
      admin_tenant.grant_user_role(user.id, admin_role.id)
        
      pm_role = roles.find_by_name(RoleNameDictionary.db_name('Project Manager'))
      tenants.each do |tenant|
        tenant.grant_user_role(user.id, pm_role.id)
      end
    end

    tenants.reload
  end
  
  def ensure_tenant_does_not_exist(attributes)
    if tenant = @tenants.find_by_name(attributes[:name])
      ComputeService.session.delete_instances_in_project(tenant)
      VolumeService.session.delete_volumes_in_project(tenant)
      users = tenant.users.reload
      users.each do |user|
        revoke_all_user_roles(user, tenant)
      end
      delete_tenant(tenant)
    end
  end

  def ensure_tenant_exists(attributes, clear = false)
    attributes        = CloudObjectBuilder.attributes_for(:tenant, attributes)
    attributes[:name] = Unique.project_name(attributes[:name])

    tenant = tenants.find_by_name(attributes[:name])

    if tenant
      tenant.update(attributes)

      # Remove instances and volumes if exist.
      if clear
        ComputeService.session.delete_instances_in_project(tenant)
        VolumeService.session.delete_volume_snapshots_in_project(tenant)
        VolumeService.session.delete_volumes_in_project(tenant)
      end
    else
      tenant = create_tenant(attributes)
    end

    # Make ConfigFile.admin_username an admin of the tenant. This is so that we
    # can manipulate it as needed. Turns out the 'admin' role in Keystone is
    # not really a global role
    admin_user  = users.find_by_name(ConfigFile.admin_username)
    raise "The user #{ ConfigFile.admin_username } could not be found!" unless admin_user

    # Make sure user has no project manager role in project
    response = service.list_roles_for_user_on_tenant(tenant.id, admin_user.id)
    manager_role = response.body['roles'].find {|r| r['name'] == RoleNameDictionary.db_name('Project Manager') }
    tenant.revoke_user_role(admin_user.id, manager_role['id']) if manager_role

    # Every tenant should be handled by admin (MCF-199,MCF-198)
    admin_role   = roles.find_by_name(RoleNameDictionary.db_name('System Admin'))
    raise "The role #{ RoleNameDictionary.db_name('System Admin') } could not be found!" unless admin_role
    tenant.grant_user_role(admin_user.id, admin_role.id)

    tenant
  end

  def ensure_user_does_not_exist(attributes)
    if user = find_user_by_name(attributes[:name])
      delete_user(user)
    end
  end
  
  # OLD ensure_user_exists() method
  #  def ensure_user_exists(attributes)
  #    user = find_user_by_name(attributes[:name])
  #    user = create_user(attributes) unless user
  #    user.password = attributes[:password]
  #    user
  #  end
  
  def ensure_user_exists(attributes)
    user = find_user_by_name(attributes[:name])
    
    unless user
      user = create_user(attributes) 
      user.password = attributes[:password]
    else
      if attributes[:password] != nil && user.password != attributes[:password]
        user.password = attributes[:password]
        user.update_password(attributes[:password])
      end
    end  
    user
  end
  
  def ensure_user_exists_is_admin_or_not(attributes, is_admin)
    user = find_user_by_name(attributes[:name])
    
    unless user
      user = create_user(attributes) 
      user.password = attributes[:password]
      
      if (is_admin.downcase == 'yes')
        admin_tenant = tenants.find_by_name('admin')
        revoke_all_user_roles(user, admin_tenant)
        ensure_tenant_role(user, admin_tenant, 'Admin')
      end
      
    else
      if attributes[:password] != nil && user.password != attributes[:password]
        user.password = attributes[:password]
        user.update_password(attributes[:password])
      end
    end  
    user
  end

  def ensure_user_exists_in_project(attributes, project, admin_role = false)
    attributes[:project_id] = project.is_a?(Fixnum) ? project : project.id
    user = find_user_by_name(attributes[:name])

    unless user
      user = create_user(attributes)


      if admin_role
        admin_tenant = tenants.find_by_name('admin')
        admin_role = roles.find_by_name(RoleNameDictionary.db_name('Project Manager'))
        admin_tenant.grant_user_role(user.id, admin_role.id)
      end
    end

    member_role = roles.find_by_name(RoleNameDictionary.db_name('Member'))
    project.grant_user_role(user.id, member_role.id)

    user.password = attributes[:password]
    user
  end

  def find_user_by_name(name)
    users.find_by_name(name)
  end

  def find_tenant_by_name(name)
    tenants.find_by_name(name)
  end

  def revoke_all_user_roles(user, tenant)
    user.roles(tenant.id).each do |role|
      tenant.revoke_user_role(user.id, role['id'])
    end

    user_name = user.name
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      user = @users.reload.find_by_name(user_name)
      raise "Roles for user #{ user.name } on tenant #{ tenant.name } took too long to revoke!" if user.roles(tenant.id).length > 0
    end
  end

  def get_generic_user(role)
    if ( role.eql?('system_admin') || role.eql?('admin') )
      user = ensure_user_exists({ :name => ConfigFile.admin_username })
      user.password = ConfigFile.admin_api_key
    else
      project = find_project_by_name(default_project_name)
      unless project
        project = ensure_tenant_exists(:name => default_project_name)
      end

      user_attrs       = CloudObjectBuilder.attributes_for(:user, :name => Unique.username(role, 32), :project_id => project.id)
      user             = ensure_user_exists_in_project(user_attrs, project, admin_role?(role))
      EnvironmentCleaner.register(:user, user.id)
    end

    user
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
