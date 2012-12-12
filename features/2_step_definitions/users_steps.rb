#=================
# GIVENs
#=================

Given /^I have a role of (.+) in the system$/ do |role_name|
  steps %{
    * Ensure that I have a role of #{ role_name } in the system
  }
end

Given /^a (system admin|admin|project manager|member) is in the system$/i do |role_name|
  steps %{
    * Ensure that a #{role_name} is in the system
  }
end

Given /^I am an? (System Admin|Member)$/ do |role_name|
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
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the users link
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
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button
    
    * The Users link should not be visible
  }
end


Then /^I can edit a user$/i do
  existing_user = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('existing'), :password => '123qwe')
  new_attrs     = CloudObjectBuilder.attributes_for(:user)

  IdentityService.session.ensure_user_does_not_exist(new_attrs)
  @existing_user = IdentityService.session.ensure_user_exists(existing_user)
  me = @current_user

  steps %{
    * Register the user named #{ existing_user.name } for deletion at exit
    * Register the user named #{ new_attrs.name } for deletion at exit

    * Ensure that a user with username #{ existing_user.name } and password #{ existing_user.password } exists
    * Ensure that a test project is available for use

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Click the context menu button for user #{ @existing_user.name }
    * Click the edit user link for user #{ @existing_user.name }
    * Fill in the Username field with #{ new_attrs.name }
    * Fill in the Email field with #{ new_attrs.email }
    * Fill in the Password field with #{ new_attrs.password }
    * Choose the 2nd item in the Primary Project dropdown
    * Click the Update User button
    * The #{ new_attrs.name } user row should be visible
  }
end


Then /^I Can Update a user with attributes (.+), (.+), (.+), (.+), (.+) and (.+)$/ do |username, email, password, primary_project, is_pm_or_not, is_admin|
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

  me = @current_user
  
  if (is_admin.downcase == 'yes')
    role_name = 'Admin'
  else
    role_name = (is_pm_or_not == "Yes" ? "Project Manager" : "Member")
  end
  
  steps %{
    * Register the user named #{ existing_username } for deletion at exit
    * Register the user named #{ new_attrs.name } for deletion at exit

    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ existing_username } and password #{ bob_password } has a role of #{ role_name }
    * Ensure that a user with username #{ new_attrs.name } does not exist
    * Ensure that I have a role of Project Manager in the project

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ me.name }
    * Fill in the Password field with #{ me.password }
    * Click the Login button

    * Click the Users link
    * Click the Edit button for the user named #{ existing_username }
    * Fill in the Username field with #{ new_attrs.name }
    * Fill in the Email field with #{ new_attrs.email }
    * Fill in the Password field with #{ new_attrs.password }
  }  
  
  if !(is_admin.downcase == 'yes')
    step "Choose the #{ primary_project_choice } item in the Primary Project dropdown"
    step "Choose the item with text #{ role } in the Role dropdown"
  end
  
  steps %{
    * Click the Update User button
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

Then /^I Cannot Update a user with attributes (.+), (.+), (.+), (.+), (.+) and (.+)$/i do |username, email, password, primary_project, is_pm_or_not, is_admin|
  existing_user = CloudObjectBuilder.attributes_for(
                    :user,
                    :name  => Unique.username('existing'),
                    :admin => (is_admin.downcase == 'yes')
                  )
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
    * Click the Edit button for the user named #{ @existing_user.name }
    * Fill in the Username field with #{ new_attrs.name }
    * Fill in the Email field with #{ new_attrs.email }
    * Fill in the Password field with #{ new_attrs.password }
  }
  
  if !(is_admin.downcase == 'yes')
    step "Choose the #{ primary_project_choice } item in the Primary Project dropdown"
    step "Choose the item with text #{ role } in the Role dropdown"
  end
  
  steps %{
    * Click the Update User button
    * The Edit User form should be visible
    * An Edit User Form Error Message element should be visible
  }
end


TestCase /^A user with a role of (.+) in the system can change user permissions$/i do |role_name|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }

    * Ensure that another user with username #{ other_username } and password #{ bob_password } exists
    * Ensure that the user #{ other_username } has a role of Member in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ other_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link

    * Click the Edit button for the user named #{ other_username }
    * Current page should have the Edit User form

    * Choose the item with text Project Manager in the Role dropdown
    * Click the Update User button
  }
end


TestCase /^A user with a role of (.+) in the system cannot change user permissions$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the system
    * Ensure that a project named #{ test_project_name } exists
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
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


TestCase /^A user with a role of (.+) in the system can create a user with (.+) permission$/i do |role_name, permission|

  user         = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('test'))

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project admin
    * Ensure that a user with username #{ user.name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the New User button
    * Fill in the Username field with #{ user.name }
    * Fill in the Email field with #{ user.email }
    * Fill in the Password field with #{ user.password }
    
    * The newly created #{ user.name } user should have a #{ permission } role
  }

end


TestCase /^A user with a role of (.+) in the system Cannot Create a user with (.+) permission$/i do |role_name, permission|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project admin
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
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


TestCase /^An authorized user can create a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, role|
  user = CloudObjectBuilder.attributes_for(
           :user,
           :name     => Unique.username(username),
           :email    => Unique.email(email),
           :password => password
         )

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Admin in the project admin
    * Ensure that a user with username #{ user.name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the New User button
    * Fill in the Username field with #{ user.name }
    * Fill in the Email field with #{ user.email }
    * Fill in the Password field with #{ user.password }
    
    * The newly created #{ user.name } user should have a #{ role } role
  }
end


TestCase /^An authorized user cannot create a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, role|
  user = CloudObjectBuilder.attributes_for(
           :user,
           :name     => ( username.downcase != '(none)' ? Unique.username(username) : username ),
           :email    => ( email.downcase != '(none)' ? Unique.email(email) : email ),
           :password => password
         )

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Admin in the project admin
    * Ensure that a user with username #{ user.name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the New User button
    * Fill in the Username field with #{ user.name }
    * Fill in the Email field with #{ user.email }
    * Fill in the Password field with #{ user.password }
    
    * A user with a role of #{ role } in a project #{ primary_project } will not be created
  }
end


TestCase /^A user with a role of (.+) in the system can delete a user$/i do |role_name|

  user = CloudObjectBuilder.attributes_for(:user, :name => test_username)

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project admin
    * Ensure that a user named #{ user.name } exists
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the context menu button for user #{ user.name }
    * Click the delete user link for user #{ user.name }
    * Click the confirm user deletion button
    
    * The user #{ user.name } should not exist in the system
  }

end


TestCase /^A user with a role of (.+) in the system Cannot (Edit|Delete) a user$/i do |role_name, action|
  
  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
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


TestCase /^An authorized user can delete the user named astark and that user will not be able to login$/ do
  user = CloudObjectBuilder.attributes_for(
           :user,
           :name     => Unique.username('astark')
         )

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Admin in the project admin
    * Ensure that a user named #{ user.name } exists
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the context menu button for user #{ user.name }
    * Click the delete user link for user #{ user.name }
    * Click the confirm user deletion button
    
    * The user #{ user.name } should not exist in the system
    
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ user.name }
    * Fill in the password field with #{ user.password }
    * Click the login button

    * Current page should be the login page
  }
end


TestCase /^A user with a role of (.+) in the system can edit a user$/i do |role_name|

  user           = CloudObjectBuilder.attributes_for(:user, :name => test_username)
  update_user    = CloudObjectBuilder.attributes_for(:user)

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project admin
    * Ensure that a user named #{ user.name } exists
    * Ensure that a user with username #{ update_user.name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
    * Register the user named #{ update_user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the context menu button for user #{ user.name }
    * Click the Edit User link for user #{ user.name }
    * Fill in the Username field with #{ update_user.name }
    * Fill in the Email field with #{ update_user.email }
    * Fill in the Password field with #{ update_user.password }
    * Choose the item with text #{ test_project_name } in the Primary Project dropdown
    * Click the Update User button

    * The #{ update_user.name } user row should be visible    
  }

end


TestCase /^An authorized user can edit a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, role|

  user            = CloudObjectBuilder.attributes_for(:user, :name => test_username)
  update_user     = CloudObjectBuilder.attributes_for(
                     :user,
                     :name     => Unique.username(username),
                     :email    => Unique.email(email),
                     :password => password
                    )

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Admin in the project admin
    * Ensure that a user named #{ user.name } exists
    * Ensure that a user with username #{ update_user.name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
    * Register the user named #{ update_user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the context menu button for user #{ user.name }
    * Click the Edit User link for user #{ user.name }
    
    * Fill in the Username field with #{ update_user.name }
    * Fill in the Email field with #{ update_user.email }
    * Fill in the Password field with #{ update_user.password }
    
    * The newly updated #{ user.name } user should have a #{ role } role 
  }
end


TestCase /^An authorized user cannot edit a user with attributes (.+), (.+), (.+), (.+), and (.+)$/i do |username, email, password, primary_project, role|
  user            = CloudObjectBuilder.attributes_for(:user, :name => test_username)
  update_user     = CloudObjectBuilder.attributes_for(
                     :user,
                     :name     => Unique.username(username),
                     :email    => Unique.email(email),
                     :password => password
                    )

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Admin in the project #{ test_project_name }
    * Ensure that a user named #{ user.name } exists
    * Ensure that a user with username #{ update_user.name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
    * Register the user named #{ user.name } for deletion at exit
    * Register the user named #{ update_user.name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Users link
    * Click the context menu button for user #{ user.name }
    * Click the Edit User link for user #{ user.name }
    
    * Fill in the Username field with #{ update_user.name }
    * Fill in the Email field with #{ update_user.email }
    * Fill in the Password field with #{ update_user.password }
    
    * A user with a role of #{ role } in a project #{ primary_project } will not be updated
  }
end
