Then /^A project does not have collaborator/i do
  identity_service = IdentityService.session
  @project.users.each do |user|
    next if user.name == "admin"
    identity_service.revoke_all_user_roles(user, @project)
  end
end

Step /^Ensure that a project named (.+) exists$/i do |project_name|
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => project_name)

  EnvironmentCleaner.register(:project, project.id)

  if project.nil? or project.id.empty?
    raise "Test project couldn't be initialized!"
  end

  @test_project = project
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

  @test_project = project
end

Then /^Ensure that I have a role of (.+) in the test project$/i do |role_name|

  if @test_project.nil?
    raise "No test project is available. You need to call " +
          "'* Ensure that a test project is available for use' " +
          "before this step."
  end

  identity_service = IdentityService.session
  user             = @me
  EnvironmentCleaner.register(:user, user.id)

  identity_service.revoke_all_user_roles(user, @test_project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
        "features/support/role_name_dictionary.rb and that it exists in " +
        "#{ ConfigFile.web_client_url }."
    end

    begin
      role.add_to_user(user,@test_project)
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

Then /^Ensure that I have a role of (.+) in the project$/i do |role_name|

  if @project.nil?
    raise "No Project is available. You need to call " +
          "'* Ensure that a project is available for use' " +
          "before this step."
  end

  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('rstark')
                     )

  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  identity_service.revoke_all_user_roles(user, @project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
        "features/support/role_name_dictionary.rb and that it exists in " +
        "#{ ConfigFile.web_client_url }."
    end

    begin
      role.add_to_user(user, @project)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end

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

  #get floating ip values
               
  #get volumes

  #cores

end

Then /^Quota Values should be warned with (.+) , (.+) and (.+)$/i do |floating_ip,volumes,cores|
          
end
