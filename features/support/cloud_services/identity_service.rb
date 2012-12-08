require_relative 'base_cloud_service'

class IdentityService < BaseCloudService

  attr_reader :test_tenant, :users, :tenants, :roles, :admins, :admin_tenant

  def initialize
    initialize_service Identity
    load_resources
  end

  def load_resources(reload = false)
    if reload
      @users   = service.users
      @tenants = service.tenants
      @roles   = service.roles

      test_tenant_name = 'admin'
      @test_tenant = find_test_tenant(test_tenant_name) || create_test_tenant(test_tenant_name)
      @admin_tenant = find_tenant_by_name('admin')
      @admins  = @users.select do |user|
                   service.list_roles_for_user_on_tenant(@admin_tenant.id, user.id).
                     body['roles'].compact.find {|r| r['name'] == 'admin'}
                 end
    else
      @users   ||= service.users
      @tenants ||= service.tenants
      @roles   ||= service.roles

      test_tenant_name ||= 'admin'
      @test_tenant ||= find_test_tenant(test_tenant_name) || create_test_tenant(test_tenant_name)
      @admin_tenant ||= find_tenant_by_name('admin')
      @admins  ||= @users.select do |user|
                     service.list_roles_for_user_on_tenant(@admin_tenant.id, user.id).
                       body['roles'].compact.find {|r| r['name'] == 'admin'}
                   end
    end
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
      tenant = find_tenant_by_name(tenant_name)
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
    member_role = find_role_by_friendly_name('Member')
    service.add_user_to_tenant(project.id, user.id, member_role.id)
    user
  end

  def delete_user(user)
    # Sometimes, OpenStack takes a while to complete the deletion
    # of all foreign key constraints. So we have to keep trying
    sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_long).tries do
      user.destroy
    end
  end

  def ensure_tenant_count(desired_count)
    @tenants.reload
    return if @tenants.count == desired_count
    delta_count = (@tenants.count - desired_count).abs

    delta_count.times do
      if @tenants.count > desired_count
        tenant = @tenants.pop
        tenant.destroy
      elsif @tenants.count < desired_count
        create_tenant
      end
      sleep(ConfigFile.wait_short)
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
    valid_roles = RoleNameDictionary.roles.map { |role| role[:friendly_name] }

    unless (valid_roles + ['(None)']).include?(role_name)
      raise "Unknown role '#{ role_name }'. Valid roles are #{ valid_roles.join(',') }"
    end

    revoke_all_user_roles(user, tenant) # It's for (None)

    if role_name != '(None)'
      member_role = find_role_by_friendly_name(role_name)
      user.update_tenant(tenant.id)
      service.add_user_to_tenant(tenant.id, user.id, member_role.id)
      revoke_all_user_roles(user, @admin_tenant)
      if ['System Admin', 'Admin'].include?(role_name)
        admin_role = find_role_by_friendly_name('Admin')
        (@tenants - [tenant]).each do |project|
          admin_in_tenant =
            service.list_roles_for_user_on_tenant(tenant.id, user.id).
            body['roles'].compact.find {|r| r['name'] == 'admin'}
          unless admin_in_tenant
            service.add_user_to_tenant(project.id, user.id, admin_role.id)
          end
        end
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
<<<<<<< HEAD
      revoke_all_user_roles(user, @admin_tenant)
=======
      admin_tenant = tenants.find{|t| t.name == 'admin'}
      revoke_all_user_roles(user, admin_tenant)

      admin_role   = roles.find_by_name(RoleNameDictionary.db_name('Admin'))
      admin_tenant.grant_user_role(user.id, admin_role.id)
>>>>>>> 6e0fbafbaf5b31dd4bbe3609cdc1fd42da71b0d3

      admin_role   = find_role_by_friendly_name('Admin')
      @tenants.each do |tenant|
        service.add_user_to_tenant(tenant.id, user.id, admin_role.id)
      end
    end

    tenants.reload
  end

  def ensure_tenant_does_not_exist(attributes)
    if tenant = find_tenant_by_name(attributes[:name])
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

    tenant = find_tenant_by_name(attributes[:name])

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
<<<<<<< HEAD
    manager_role = response.body['roles'].find {|r| r['name'] == RoleNameDictionary.db_name('Project Manager') }
    tenant.revoke_user_role(admin_user.id, manager_role['id']) if manager_role

    add_admins_to_tenant(tenant)

=======
    response_manager_role = response.body['roles'].find {|r| r['name'] == RoleNameDictionary.db_name('Project Manager') }
    
    if response_manager_role
      tenant.revoke_user_role(admin_user.id, response_manager_role['id'])
      sleep(ConfigFile.wait_long)
    end
    
    manager_role   = roles.find_by_name(RoleNameDictionary.db_name('Project Manager'))
    raise "The role #{ RoleNameDictionary.db_name('Project Manager') } could not be found!" unless manager_role
    tenant.grant_user_role(admin_user.id, manager_role.id)
    
    # Every tenant should be handled by admin (MCF-199,MCF-198)
    response_admin_role = response.body['roles'].find {|r| r['name'] == RoleNameDictionary.db_name('Admin') }
    
    if response_admin_role
      tenant.revoke_user_role(admin_user.id, response_admin_role['id']) 
      sleep(ConfigFile.wait_long)
    else
      admin_role   = roles.find_by_name(RoleNameDictionary.db_name('Admin'))
      raise "The role #{ RoleNameDictionary.db_name('Admin') } could not be found!" unless admin_role
      tenant.grant_user_role(admin_user.id, admin_role.id)
    end
    
>>>>>>> 6e0fbafbaf5b31dd4bbe3609cdc1fd42da71b0d3
    tenant
  end

  def ensure_new_tenant_exists(attributes, clear = false)
    attributes        = CloudObjectBuilder.attributes_for(:tenant, attributes)
    attributes[:name] = Unique.project_name(attributes[:name])

    tenant = find_tenant_by_name(attributes[:name])

    if tenant
      # Remove instances and volumes if exist.
      if clear
        ComputeService.session.delete_instances_in_project(tenant)
        VolumeService.session.delete_volume_snapshots_in_project(tenant)
        VolumeService.session.delete_volumes_in_project(tenant)
      end

      tenant.destroy
    end

    tenant = create_tenant(attributes)

    # Make ConfigFile.admin_username an admin of the tenant. This is so that we
    # can manipulate it as needed. Turns out the 'admin' role in Keystone is
    # not really a global role
    admin_user  = users.find_by_name(ConfigFile.admin_username)
    raise "The user #{ ConfigFile.admin_username } could not be found!" unless admin_user

    # Make sure user has no project manager role in project
    response = service.list_roles_for_user_on_tenant(tenant.id, admin_user.id)
    manager_role = response.body['roles'].find {|r| r['name'] == RoleNameDictionary.db_name('Project Manager') }
    tenant.revoke_user_role(admin_user.id, manager_role['id']) if manager_role

    add_admins_to_tenant(tenant)

    tenant
  end

  def ensure_user_does_not_exist(attributes)
    if user = find_user_by_name(attributes[:name])
      delete_user(user)
    end
  end

  def ensure_user_exists(attributes)
    user = find_user_by_name(attributes[:name])
    admin = !!attributes.delete(:admin)

    unless user
      user = create_user(attributes)
      user.password = attributes[:password]

      if admin
        revoke_all_user_roles(user, @admin_tenant)
        ensure_tenant_role(user, @admin_tenant, 'Admin')
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
    attributes.merge!(project_id: (project.is_a?(Fixnum) ? project : project.id),
                      admin: admin_role)

    user = ensure_user_exists(attributes)

    revoke_all_user_roles(user, project)
    member_role = find_role_by_friendly_name('Member')
    unless project.roles_for(user).include?(member_role)
      service.add_user_to_tenant(project.id, user.id, member_role.id)
    end

    user
  end

  def find_role_by_friendly_name(name)
    role_name = RoleNameDictionary.db_name(name)
    if role = @roles.find_by_name(role_name)
      return role
    else
      raise "Couldn't find role #{ role_name }!"
    end
  end

  def find_user_by_name(name)
    @users.find_by_name(name)
  end

  def find_tenant_by_name(name)
    @tenants.find_by_name(name)
  end

  def revoke_all_user_roles(user, tenant)
    service.list_roles_for_user_on_tenant(tenant.id, user.id).body['roles'].compact.each do |role|
      service.remove_user_from_tenant(tenant.id, user.id, role['id'])
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

  def add_admins_to_tenant(tenant)
    admin_role = find_role_by_friendly_name('Admin')
    admins = @users.select do |user|
               service.list_roles_for_user_on_tenant(@admin_tenant.id, user.id).
                 body['roles'].compact.find {|r| r['name'] == 'admin'}
             end

    admins.each do |admin|
      unless tenant.roles_for(admin).include?(admin_role)
        begin
          service.add_user_to_tenant(tenant.id, admin.id, admin_role.id)
        rescue
          # ignore conflict exception (TODO: implement smart logic.)
        end
      end
    end
  end

  def create_test_tenant(name)
    attributes = CloudObjectBuilder.attributes_for(:tenant, :name => name)
    tenant = tenants.new(attributes)
    tenant.save
    tenant
  end

  def find_test_tenant(name)
    @tenants.find_by_name(name)
  end
end
