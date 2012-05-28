#=================
# GIVENs
#=================

Given /^I have a role of (.+) in the system$/ do |role_name|
  steps %{
    * Ensure that I have a role of #{ role_name } in the system
  }
end

Given /^I am an? (System Admin|User)$/ do |role_name|
  steps %{
    * Ensure that I have a role of #{ role_name } in the system
  }
end


Given /^My username is (.+) and my password is (.+)$/ do |username, password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
  }
end

Given /^[Aa] user with a role of (.+) exists in the project$/ do |role_name|
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
  EnvironmentCleaner.register(:user, user.id)

  # Make variable(s) available for use in succeeding steps
  @user = user
end

Given /^I am authorized to create users in the system$/ do
  steps %{
    * Ensure that I have a role of System Admin in the system
  }
end


Given /^I am authorized to delete users$/ do
  steps %{
    * Ensure that I have a role of System Admin in the system
  }
end

#=================
# WHENs
#=================

When /^I delete the user (.+)$/ do |username|
  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Click the users link
    * Current page should be the users page
    * Click the context menu button for user #{ username }
    * Click the delete user link for user #{ username }
    * Click the confirm user deletion button
  }

end

#=================
# THENs
#=================

Then /^user (.+) will be deleted$/ do |user_name|
  steps %{
    * The user #{ user_name } should not exist in the system
  }
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

Then /^I can create a user$/i do
  new_user = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('new'))
  me       = @me

  steps %{
    * Register the user named #{ new_user.name } for deletion at exit

    * Ensure that a user with username #{ new_user.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the test project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Current page should be the Users page
    * Click the New User button
    * Fill in the Username field with #{ new_user.name }
    * Fill in the Email field with #{ new_user.email }
    * Fill in the Password field with #{ new_user.password }
    * Choose the 2nd item in the Primary Project dropdown
    * Check the Project Manager checkbox
    * Click the Create User button
    * The New User form should not be visible
    * The #{ new_user.name } user row should be visible
  }
end

Then /^I cannot create a user$/i do
  me = @me

  steps %{
    * Click the Logout button if currently logged in

    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * The Users link should not be visible
  }
end


Then /^I can create a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, is_pm_or_not|
  new_user = CloudObjectBuilder.attributes_for(
               :user,
               :name     => Unique.username(username),
               :email    => Unique.email(email),
               :password => password
             )
  primary_project_choice = case primary_project
                           when '(Any)'
                             '2nd'
                           when '(None)'
                             '1st'
                           end

  check_or_uncheck = (is_pm_or_not == "Yes" ? "Check" : "Uncheck")
  me       = @me

  steps %{
    * Register the user named #{ new_user.name } for deletion at exit

    * Ensure that a user with username #{ new_user.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the test project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Current page should be the Users page
    * Click the New User button
    * Fill in the Username field with #{ new_user.name }
    * Fill in the Email field with #{ new_user.email }
    * Fill in the Password field with #{ new_user.password }
    * Choose the #{ primary_project_choice } item in the Primary Project dropdown
    * #{ check_or_uncheck } the Project Manager checkbox
    * Click the Create User button
    * The New User form should not be visible
    * The #{ new_user.name } user row should be visible
  }
end


Then /^I cannot create a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, is_pm_or_not|
  new_user = CloudObjectBuilder.attributes_for(
               :user,
               :name     => ( username.downcase == "(none)" ? username : Unique.username(username) ),
               :email    => ( email.downcase == "(none)" ? email : Unique.email(email) ),
               :password => password
             )
  primary_project_choice = case primary_project
                           when '(Any)'
                             '2nd'
                           when '(None)'
                             '1st'
                           end

  check_or_uncheck = (is_pm_or_not == "Yes" ? "Check" : "Uncheck")
  me       = @me

  steps %{
    * Register the user named #{ new_user.name } for deletion at exit

    * Ensure that a user with username #{ new_user.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the test project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Current page should be the Users page
    * Click the New User button
    * Fill in the Username field with #{ new_user.name }
    * Fill in the Email field with #{ new_user.email }
    * Fill in the Password field with #{ new_user.password }
    * Choose the #{ primary_project_choice } item in the Primary Project dropdown
    * #{ check_or_uncheck } the Project Manager checkbox
    * Click the Create User button
    * The New User form should be visible
    * A New User Form Error Message element should be visible
  }
end


Then /^I [Cc]an [Dd]elete (?:that|the) user (.+)$/ do |username|
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Click the users link
    * Current page should be the users page
    * Click the context menu button for user #{ username }
    * Click the delete user link for user #{ username }
    * Click the confirm user deletion button
    * The user #{ username } should not exist in the system
  }
end

Then /^I [Cc]annot [Dd]elete (?:that|the) user (.+)$/ do |user_name|
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button
    * The Users link should not be visible
  }
end
