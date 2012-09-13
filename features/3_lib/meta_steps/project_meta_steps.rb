Then /^A project does not have collaborator/i do
  identity_service = IdentityService.session
  @project.users.each do |user|
    next if user.name == "admin"
    identity_service.revoke_all_user_roles(user, @project)
  end
end

Then /^A quota edit dialog show error/i do
  element_name =  "quota edit error element".split.join('_').downcase
  element_name2 = "quota edit error2 element".split.join('_').downcase
  if ( !@current_page.send("has_#{ element_name }?") &&
      !@current_page.send("has_#{ element_name2 }?")  )
    raise "A quota edit should show error, but it does not."
  end
end

Step /^Ensure that a project named (.+) exists$/i do |project_name|
  project_name.strip!
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => project_name)

  EnvironmentCleaner.register(:project, project.id)

  if project.nil? or project.id.empty?
    raise "Test project couldn't be initialized!"
  end

  @named_project = project
end

Step /^Ensure that a project named (.+) does not exists$/i do |project_name|
  identity_service = IdentityService.session
  project          = identity_service.ensure_tenant_does_not_exist(:name => project_name)

  if project
    EnvironmentCleaner.register(:project, project.id)
  end
end

Step /^Ensure that the project named (.+) has (\d+) instances?$/i do |project_name, instance_count|
  instance_count   = instance_count.to_i
  project          = IdentityService.session.ensure_project_exists(:name => project_name)

  raise "Project named #{ project_name } couldn't be found!" if project.nil? or project.id.empty?

  EnvironmentCleaner.register(:project, project.id)
  ComputeService.session.ensure_active_instance_count(project, instance_count)
end

Then /^Ensure that a test project is available for use$/i do
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => 'project')

  EnvironmentCleaner.register(:project, project.id)

  if project.nil? or project.id.empty?
    raise "Test project couldn't be initialized!"
  end

  @named_project = project
end

Then /^Ensure that I have a role of (.+) in the named project$/i do |role_name|

  if @named_project.nil?
    raise "No test project is available. You need to call " +
          "'* Ensure that a test project is available for use' " +
          "before this step."
  end

  identity_service = IdentityService.session
  user             = @current_user

  identity_service.revoke_all_user_roles(user, @named_project)
  admin_project = identity_service.tenants.find { |t| t.name == 'admin' }
  identity_service.revoke_all_user_roles(user, admin_project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    # 2012-09-12
    # mcloud implement project role like this
    # If you are member. only have a member role of @named_project.
    # If you are project manager of named_project, you have a member role of @named_project
    # and have admin role of admin project.  
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name('Member'))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
        "features/support/role_name_dictionary.rb and that it exists in " +
        "#{ ConfigFile.web_client_url }."
    end

    begin
      if RoleNameDictionary.db_name(role_name) == "admin"  then
        identity_service.ensure_tenant_role(user, admin_project, 'System Admin')
      end
      role.add_to_user(user,@named_project)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end
end

Then /^Ensure that a project is available for use$/i do
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => 'project')

  EnvironmentCleaner.register(:project, project.id)

  if project.nil? or project.id.empty?
    raise "Project couldn't be initialized!"
  end

  @project = project
end

Step /^Ensure that a user exists in the project$/ do
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => bob_username
                     )
  user             = IdentityService.session.ensure_user_exists_in_project(user_attrs, @project)
  # Check if user is nil, then raise error message.
  if user.nil? or user.id.empty?
    raise "User couldn't be initialized!"
  end
  # Register user for deletion.
  EnvironmentCleaner.register(:user, user.id)
  # Make variable(s) available for use in succeeding steps
  @current_user = user
end

Then /^Ensure that I have a role of (.+) in the project$/i do |role_name|

  if @project.nil?
    raise "No Project is available. You need to call " +
          "'* Ensure that a project is available for use' " +
          "before this step."
  end

  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => bob_username
                     )

  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  identity_service.revoke_all_user_roles(user, @project)
  admin_project = identity_service.tenants.find { |t| t.name == 'admin' }
  identity_service.revoke_all_user_roles(user, admin_project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    # 2012-09-12
    # mcloud implement project role like this
    # If you are member. only have a member role of @project.
    # If you are project manager of named_project, you have a member role of @project
    # and have admin role of admin project.  
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name('Member'))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
        "features/support/role_name_dictionary.rb and that it exists in " +
        "#{ ConfigFile.web_client_url }."
    end

    begin
      if RoleNameDictionary.db_name(role_name) == "admin"  then
        identity_service.ensure_tenant_role(user, admin_project, 'System Admin')
      end
      role.add_to_user(user,project)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user
end

Then /^Ensure that the project has no security groups$/i do
  compute_service = ComputeService.session
  compute_service.ensure_project_security_group_count(@project, 0)
end

Then /^Ensure that the project has a security group$/i do
  compute_service = ComputeService.session
  compute_service.ensure_project_security_group_count(@project, 1)
end

Then /^Ensure that the a project has an instance$/ do
  compute_service = ComputeService.session
  compute_service.ensure_active_instance_count(@project, 1)
end

Step /^Ensure that the project (.+) has an instance$/ do |project|
  project = @project

  if project
    compute_service = ComputeService.session
    compute_service.ensure_active_instance_count(project, 1)
  end
end

Then /^Ensure that a project has (\d+) security groups$/ do |security_group_count|
  compute_service = ComputeService.session
  compute_service.ensure_project_security_group_count(@project, security_group_count.to_i)
end

Then /^Parse and set (.+) quota value with (.+)$/i do |quota_type, value|

  @current_page.send("#{ quota_type } quota edit field").set value

end

Then /^Register the project named (.+) for deletion at exit$/i do |name|
  project = IdentityService.session.tenants.reload.find { |p| p.name == name }
  EnvironmentCleaner.register(:project, project.id) if project
end

Then /^Select Collaborator (.+)$/ do |username|
  @current_page.collaborators_email_link.click
  sleep(1)
  @current_page.collaborator_option( name: @user.email ).click
end

Then /^Quota Values should be updated with (.+) , (.+) and (.+)$/i do |floating_ip,volumes,cores|
  @pending
end

Then /^Quota Values should be warned with (.+) , (.+) and (.+)$/i do |floating_ip,volumes,cores|
  @pending
end

Then /^Edit the (.+) project$/i do |project_name|
  project_name.strip!
  @current_page.project_menu_button( name: project_name ).click
  @current_page.edit_project_link( name: project_name ).click
  @current_page = ProjectPage.new
end

Then /^Delete the (.+) project$/i do |project_name|
  project_name.strip!
  @current_page.project_menu_button( name: project_name ).click
  @current_page.delete_project_link( name: project_name ).click
  @current_page.delete_confirmation_button.click
end

Step /^Ensure that the project named (.+) has (?:an|a) (member|project manager) named (.+)$/i do |project_name, role, username|
  project_name.strip!
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  user_attrs       = CloudObjectBuilder.attributes_for(:user, :name => Unique.username(username), :project_id => project.id)
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists_in_project(user_attrs, project, admin_role?(role))

  EnvironmentCleaner.register(:user, user.id)
end
