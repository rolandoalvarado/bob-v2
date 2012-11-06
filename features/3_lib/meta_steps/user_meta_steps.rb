Step /^Ensure that the current user is logged in$/ do
  @current_page ||= RootPage.new
  @current_page.visit

  if @current_page.actual_url.empty? # Logged Out?
    step %{
      * Visit the login page
      * Fill in the username field with #{ @current_user.name }
      * Fill in the password field with #{ @current_user.password }
      * Click the login button
    }
  end
end

Step /^Ensure that (?:a|another) user with username (.+) and password (.+) exists$/i do |username, password|
  username         = Unique.username(username)
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => username,
                       :password => password
                     )

  identity_service = IdentityService.session
  user = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  #if user has project , reset roles for next steps
  identity_service.revoke_all_user_roles(user, @project) if @project != nil
  
  # Make variable(s) available for use in succeeding steps
  @existing_user = @user = user
end

Step /^Ensure that (?:a|another) user with username (.+) and password (.+) has a role of (.+)$/i do |username, password, role_name|
  username         = Unique.username(username)
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => username,
                       :password => password
                     )

  identity_service = IdentityService.session
  user = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  #if user has project , reset roles for next steps
  identity_service.revoke_all_user_roles(user, @project) if @project != nil
  
  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    begin
      identity_service.ensure_tenant_role(user, @project, role_name)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role_name }"
    end
  end
  
  # Make variable(s) available for use in succeeding steps
  @existing_user = @user = user
end


Step /^Ensure that (?:a|another) user named (.+) exists$/i do |username|
  username           = Unique.username(username)
  @user_attrs        = CloudObjectBuilder.attributes_for(:user, :name => username, :password => bob_password || '123qwe')
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
  user_attrs = CloudObjectBuilder.attributes_for(:user, name: bob_username, password: bob_password )
  identity_service = IdentityService.session

  user = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  admin_project = identity_service.tenants.find { |t| t.name == 'admin' }
  if admin_project.nil? or admin_project.id.empty?
    raise "Project couldn't be found!"
  end

  identity_service.revoke_all_user_roles(user, admin_project)

  # Ensure user has the following role in the system
  if role_name.downcase == "member"
    role_name = "Member"
    step "A project exists in the system"
  end

  begin
    if role_name.downcase == "member"
      identity_service.ensure_tenant_role(user,  @project, role_name)
    else
      identity_service.ensure_tenant_role(user, admin_project, role_name)
    end
  rescue Fog::Identity::OpenStack::NotFound => e
    raise "Couldn't add #{ user.name } to #{ admin_project.name } as #{ role_name }"
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user
end

Given /^Ensure that a (.*) is in the system$/i do |role_name|
  role_name = role_name.downcase.strip.gsub(' ', '_')

  @users ||= Hash.new
  if @current_user = @users[role_name]
    @current_user
  else
    @current_user = @users[role_name] =
      IdentityService.session.get_generic_user(role_name)
  end
end

Step /^Ensure that the user (.+) has a role of (.+) in the project (.+)$/ do |username, role_name, project_name|
  user_attrs       = CloudObjectBuilder.attributes_for( :user, :name => username )
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

  EnvironmentCleaner.register(:user, user.id)

  project = identity_service.tenants.reload.find { |t| t.name == project_name }
  raise "The project named #{ project_name } couldn't be found!" if project.nil? or project.id.empty?

  identity_service.revoke_all_user_roles(user, project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    begin
      identity_service.ensure_tenant_role(user, project, role_name)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role_name }"
    end
  end  
end

Step /^Ensure that the user (.+) (?:does not have a role in|is not a member of) the project (.+)$/ do |username, project_name|
  user_attrs       = CloudObjectBuilder.attributes_for :user, :name => Unique.username(username)
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

  project = identity_service.tenants.reload.find { |t| t.name == project_name }
  raise "The project named #{ project_name } couldn't be found!" if project.nil? or project.id.empty?

  identity_service.revoke_all_user_roles(user, project)
end

Step /^Ensure that the user (.+) does not have a role in the system$/ do |username|
  user_attrs       = CloudObjectBuilder.attributes_for :user, :name => Unique.username(username)
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

  identity_service.tenants.each do |project|
    raise "The project named #{ project_name } couldn't be found!" if project.nil? or project.id.empty?
    identity_service.revoke_all_user_roles(user, project)
  end
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
