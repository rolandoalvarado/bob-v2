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
    * Ensure that a user with username #{ username } and password 123qwe exists
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

  user             = IdentityService.session.ensure_user_exists(user_attrs)

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


Given /^I am authorized to edit users in the system$/ do
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
  me       = @current_user

  steps %{
    * Register the user named #{ new_user.name } for deletion at exit

    * Ensure that a user with username #{ new_user.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the named project

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
    * Choose the item with text Project Manager in the Role dropdown
    * Click the Create User button
    * The New User form should be visible
    * The #{ new_user.name } user row should be visible
  }
end

Then /^I cannot create a user$/i do
  me = @current_user

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

  role = (is_pm_or_not == "Yes" ? "Project Manager" : "Member")
  me       = @current_user

  steps %{
    * Register the user named #{ new_user.name } for deletion at exit

    * Ensure that a user with username #{ new_user.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the named project

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
    * Choose the item with text #{ role } in the Role dropdown
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

  role = (is_pm_or_not == "Yes" ? "Project Manager" : "Member")
  me       = @current_user

  steps %{
    * Register the user named #{ new_user.name } for deletion at exit

    * Ensure that a user with username #{ new_user.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the named project

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
    * Choose the item with text #{ role } in the Role dropdown
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


Then /^I can edit a user$/i do
  existing_user = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('existing'), :password => '123qwe')
  new_attrs     = CloudObjectBuilder.attributes_for(
                    :user,
                    :name     => ( Unique.username('new_user') ),
                    :email    => ( Unique.email('new_email@mail.com') ),
                    :password => '123qwe'
                  )

  IdentityService.session.ensure_user_does_not_exist(new_attrs)
  @existing_user = IdentityService.session.ensure_user_exists(existing_user)
  me = @current_user

  steps %{
    * Register the user named #{ existing_user.name } for deletion at exit
    * Register the user named #{ new_attrs.name } for deletion at exit

    * Ensure that a user with username #{ existing_user.name } and password #{ existing_user.password } exists
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the named project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Current page should be the Users page
    * Click the Edit button for the user named #{ @existing_user.name }
    * Fill in the Username field with #{ new_attrs.name }
    * Fill in the Email field with #{ new_attrs.email }
    * Choose the 2nd item in the Primary Project dropdown
    * Click the Update User button
    * The Edit User form should not be visible
    * The #{ new_attrs.name } user row should be visible
  }
end


Then /^I can update a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, is_pm_or_not|
  existing_user = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('existing'), :password => '123qwe')
  new_attrs     = CloudObjectBuilder.attributes_for(
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

  role = (is_pm_or_not == "Yes" ? "Project Manager" : "Member")

  IdentityService.session.ensure_user_does_not_exist(new_attrs)
  @existing_user = IdentityService.session.ensure_user_exists(existing_user)
  me = @current_user

  steps %{
    * Register the user named #{ existing_user.name } for deletion at exit
    * Register the user named #{ new_attrs.name } for deletion at exit

    * Ensure that a user with username #{ existing_user.name } and password #{ existing_user.password } exists
    * Ensure that a user with username #{ new_attrs.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the named project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Current page should be the Users page
    * Click the Edit button for the user named #{ @existing_user.name }
    * Fill in the Username field with #{ new_attrs.name }
    * Fill in the Email field with #{ new_attrs.email }
    * Fill in the Password field with #{ new_attrs.password }
    * Choose the #{ primary_project_choice } item in the Primary Project dropdown
    * Choose the item with text #{ role } in the Role dropdown
    * Click the Update User button
    * The Edit User form should not be visible
    * The #{ new_attrs.name } user row should be visible
  }
end


Then /^I cannot edit a user$/i do
  me = @current_user

  steps %{
    * Click the Logout button if currently logged in

    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * The Users link should not be visible
  }
end


Then /^I cannot update a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, is_pm_or_not|
  existing_user = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('existing'))
  new_attrs     = CloudObjectBuilder.attributes_for(
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

  role = (is_pm_or_not == "Yes" ? "Project Manager" : "Member")

  @existing_user = IdentityService.session.ensure_user_exists(existing_user)
  me = @current_user

  steps %{
    * Register the user named #{ existing_user.name } for deletion at exit
    * Register the user named #{ new_attrs.name } for deletion at exit

    * Ensure that a user with username #{ existing_user.name } and password 123qwe exists
    * Ensure that a user with username #{ new_attrs.name } does not exist
    * Ensure that a test project is available for use
    * Ensure that I have a role of Project Manager in the named project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Current page should be the Users page
    * Click the Edit button for the user named #{ @existing_user.id }
    * Fill in the Username field with #{ new_attrs.name }
    * Fill in the Email field with #{ new_attrs.email }
    * Fill in the Password field with #{ new_attrs.password }
    * Choose the #{ primary_project_choice } item in the Primary Project dropdown
    * Choose the item with text #{ role } in the Role dropdown
    * Click the Update User button
    * The Edit User form should be visible
    * An Edit User Form Error Message element should be visible
  }
end


TestCase /^A user with a role of (System Admin|\(None\)) in the system can change user permissions$/i do |role_name|

  pm_username     = Unique.username('pm')
  member_username = Unique.username('member')
  project_name    = Unique.project_name('test')

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the system

    * Ensure that a project named #{ project_name } exists
    * Ensure that another user with username #{ pm_username } and password #{ bob_password } exists
    * Ensure that the user #{ pm_username } has a role of Project Manager in the project #{ project_name }
    * Ensure that another user with username #{ member_username } and password #{ bob_password } exists
    * Ensure that the user #{ member_username } has a role of Member in the project #{ project_name }
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ pm_username } for deletion at exit
    * Register the user named #{ member_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link

    * Click the Edit button for the user named #{ pm_username }
    * Current page should have the Edit User form

    * Choose the item with text Member in the Role dropdown
    * Click the Update User button

    * The item with text Member should be default in the Role dropdown

    * Click the Edit button for the user named #{ member_username }
    * Current page should have the Edit User form

    * Choose the item with text Project Manager in the Role dropdown
    * Click the Update User button

    * The item with text Project Manager should be default in the Role dropdown
  }

end


TestCase /^A user with a role of (Project Manager|Member) in the system can change user permissions$/i do |role_name|

  pm_username     = Unique.username('pm')
  member_username = Unique.username('member')
  project_name    = Unique.project_name('test')

  Preconditions %{
    * Ensure that a project named #{ project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ project_name }

    * Ensure that another user with username #{ pm_username } and password #{ bob_password } exists
    * Ensure that the user #{ pm_username } has a role of Project Manager in the project #{ project_name }
    * Ensure that another user with username #{ member_username } and password #{ bob_password } exists
    * Ensure that the user #{ member_username } has a role of Member in the project #{ project_name }
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ pm_username } for deletion at exit
    * Register the user named #{ member_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link

    * Click the Edit button for the user named #{ pm_username }
    * Current page should have the Edit User form

    * Choose the item with text Member in the Role dropdown
    * Click the Update User button

    * The item with text Member should be default in the Role dropdown

    * Click the Edit button for the user named #{ member_username }
    * Current page should have the Edit User form

    * Choose the item with text Project Manager in the Role dropdown
    * Click the Update User button

    * The item with text Project Manager should be default in the Role dropdown
  }

end


TestCase /^A user with a role of (.+) in the system cannot change user permissions$/i do |role_name|

  username      = Unique.username('test')
  password      = '123qwe'
  project_name  = Unique.project_name('test')

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the system

    * Ensure that a project named #{ project_name } exists
    * Ensure that another user with username #{ username } and password #{ password } exists
    * Ensure that the user #{ username } has a role of Member in the project #{ project_name }
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * The Users link should not be visible
  }

end
