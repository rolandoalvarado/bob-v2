Step /^Ensure that (?:a|another) user with username (.+) and password (.+) exists$/i do |username, password|
  username           = Unique.username(username)
  @user_attrs        = CloudObjectBuilder.attributes_for(:user, :name => username, :password => password)
  @existing_user = @user = IdentityService.session.ensure_user_exists(@user_attrs)
  EnvironmentCleaner.register(:user, @user.id)
end


Then /^Ensure that a user with username (.+) does not exist$/i do |username|
  user_attrs = CloudObjectBuilder.attributes_for(:user, :name => username)
  IdentityService.session.ensure_user_does_not_exist(user_attrs)
end

Then /^Ensure that the user (.+) has a role of (.+) in the system$/i do |user_name ,role_name|
  step "Ensure that the user #{ user_name } has a role of #{ role_name } in the project admin"
end

Then /^Ensure that I have a role of (.+) in the system$/i do |role_name|

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


Step /^Ensure that the user (.+) has a role of (.+) in the project (.+)$/ do |username, role_name, project_name|
  user_attrs       = CloudObjectBuilder.attributes_for( :user, :name => Unique.username(username) )
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

  EnvironmentCleaner.register(:user, user.id)

  project = identity_service.tenants.reload.find { |t| t.name == project_name }
  raise "The project named #{ project_name } couldn't be found!" if project.nil? or project.id.empty?

  identity_service.revoke_all_user_roles(user, project)

  if role_name.downcase == "user"
    role_name = "Member"
  end
  identity_service.ensure_project_role(user, project, role_name)
end


Then /^Register the user named (.+) for deletion at exit$/i do |username|
  EnvironmentCleaner.register(:user, :name => username)
end


Then /^The user (.+) should not exist in the system$/i do |username|
  username = Unique.username(username)

  sleeping(1).seconds.between_tries.failing_after(20).tries do
    user = IdentityService.session.users.find_by_name(username)
    raise "User #{ username } should not exist, but it does." if user
  end
end
