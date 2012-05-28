Then /^Ensure that a user with username (.+) and password (.+) exists$/ do |username, password|
  username           = Unique.username(username)
  @user_attrs        = CloudObjectBuilder.attributes_for(:user, :name => username, :password => password)
  @user_attrs[:name] = Unique.username(@user_attrs[:name])
  @user = IdentityService.instance.ensure_user_exists(@user_attrs)
  EnvironmentCleaner.register(:user, @user.id)
end

Then /^Ensure that a user with username (.+) does not exist$/ do |username|
  user = IdentityService.session.users.reload.find { |u| u.name == username }
  IdentityService.session.delete_user(user) if user
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
  @me = @current_user = user
end


Then /^Register the user named (.+) for deletion at exit$/i do |username|
  EnvironmentCleaner.register(:user, :name => username)
end


Then /^The user (.+) should not exist in the system$/ do |username|
  username = Unique.username(username)

  sleeping(1).seconds.between_tries.failing_after(20).tries do
    user = IdentityService.session.users.find_by_name(username)
    raise "User #{ username } should not exist, but it does." if user
  end
end
