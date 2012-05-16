#=================
# GIVENs
#=================

Given /^I have a role of (.+) in the system$/ do |role_name|
  steps %{
    * I am a #{ role_name }
  }
end

Given /^I am an? (System Admin|User)$/ do |role_name|
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('rstark')
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


Given /^My username is (.+) and my password is (.+)$/ do |username, password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
  }
end

Given /^[Aa] user with a role of (.+) exists in the project$/ do |role_name|
  # identity_service = IdentityService.instance
  # @user_attrs      = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('rstark'))
  # user             = identity_service.ensure_user_exists(@user_attrs)
  #
  # role_name = RoleNameDictionary.db_name(friendly_name)
  # role      = identity_service.roles.find_by_name(role_name)
  # @project.add_user(user.id, role.id)

  username = 'rstark'

  steps %{
    * Ensure that a user with username #{ username } exists
    * Ensure that the user has a role of #{ role_name }
    * Raise an error if the user does not have a role of #{ role_name }
  }

  pending # express the regexp above with the code you wish you had
end

Given /^A user named (.+) exists in the system$/ do |user_name|
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username(user_name)
                     )
  identity_service = IdentityService.session

  user             = identity_service.ensure_user_exists(user_attrs)

  if user.nil? or user.id.empty?
    raise "User couldn't be initialized!"
  end

  # Make variable(s) available for use in succeeding steps
  @user = user
end

Given /^I am authorized to delete users$/ do
  steps %{
    * I am a System Admin
  }
end

#=================
# WHENs
#=================

When /^I delete the user (.+)$/ do |user_name|
  user_name = Unique.name(user_name).gsub(' ', '_')

  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the users page
    * The #{ user_name } user should be visible

    * Delete the #{ user_name } user
  }

end

#=================
# THENs
#=================
 
Then /^user (.+) will be deleted$/ do |user_name|
  user_name = Unique.name(user_name).gsub(' ', '_')
  user      = IdentityService.session.users.select { |u| u.name == user_name }.first

  if user != nil && user.id != nil
    raise "User #{ user_name } should be deleted, but is not."
  end
end

Then /^s?he will not be able to log in$/ do 
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password } 
    * Click the login button

    * Current page should be the login page
  }
end

Then /^I [Cc]an [Dd]elete (?:that|the) user (.+)$/ do |user_name|
  user_name = Unique.name(user_name).gsub(' ', '_')

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the users page
    * The #{ @user.name } user should be visible

    * Delete the #{ user_name } user
  }

  user =  IdentityService.session.tenants.find_by_name(@user.name)

  if user != nil && user.id != nil
     raise "User #{ user.name } should be deleted, but is not."
  end

end

Then /^I [Cc]annot [Dd]elete (?:that|the) user (.+)$/ do |user_name|
  user_name = Unique.name(user_name).gsub(' ', '_')

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the root page
  }

  if ( @current_page.has_user_page_link? )
    raise "The user page link should not have been created, but it seems that it was."
  end

end
