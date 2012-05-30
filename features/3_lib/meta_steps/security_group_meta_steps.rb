Then /^Ensure that I have a role of (.+) in the project$/i do |role_name|
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('bob')
                     )
  identity_service = IdentityService.session

  user             = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  admin_project = identity_service.tenants.find { |t| t.name == 'admin' }
  if admin_project.nil? or admin_project.id.empty?
    raise "Project couldn't be found!"
  end

  identity_service.revoke_all_user_roles(user, admin_project)

  # Ensure user has the following role in the system
  if role_name.downcase == "user"
    role_name = "Member"
  end

  role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))
  if role.nil?
    raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
      "features/support/role_name_dictionary.rb and that it exists in " +
      "#{ ConfigFile.web_client_url }."
  end

  begin
    admin_project.grant_user_role(user.id, role.id)
  rescue Fog::Identity::OpenStack::NotFound => e
    raise "Couldn't add #{ user.name } to #{ admin_project.name } as #{ role.name }"
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user
end

Then /^Ensure that (.+) exist$/i do |security_group|
  compute_service = ComputeService.session
  security_group  = compute_service.find_security_group_by_name(@project, security_group)

  if security_group
    compute_service.ensure_project_security_group_count(@project, security_group.count)  
  else
    raise "Security Group couldn't be found!"
  end
  
  EnvironmentCleaner.register(:project, @project.id)

  @security_group = security_group
end

Then /^Ensure that the project has no security groups$/i do
  compute_service = ComputeService.session
  compute_service.ensure_project_security_group_count(@project, 0)
end
