Then /^If my username is (.+) and my password is (.+), I can log in with the following credentials (.+), (.+)$/i do |username, password, typed_username, typed_password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } has a role of System Admin
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ Unique.username(typed_username) }
    * Fill in the password field with #{ typed_password }
    * Click the login button

    * Current page should have the Logout button
  }
end


Then /^If my username is (.+) and my password is (.+), I cannot log in with the following credentials (.+), (.+)$/i do |username, password, typed_username, typed_password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } has a role of System Admin
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ Unique.username(typed_username) }
    * Fill in the password field with #{ typed_password }
    * Click the login button

    * Current page should be the Login page
    * The Login Error message should be visible
  }
end


Then /^I will be redirected to the Log In page when I anonymously access (.+)$/i do |page_name|
  steps %{
    * Click the Logout button if currently logged in
    * Visit the #{ page_name } page
    * Current page should be the Login page
  }
end


Then /^Logging in after anonymously accessing (.+) redirects me back to it$/ do |page_name|
  steps %{
    * Ensure that a project named bob-authentication exists
    * Ensure that the project named #{ test_project_auth } has a project manager named #{ bob_redirect_username }
    * Register the user named #{ bob_redirect_username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the #{ page_name } page
    * Current page should be the Login page
    * Fill in the username field with #{ bob_redirect_username }
    * Fill in the password field with #{ bob_password }
    * Click the Login button
    * Current page should be the #{ page_name } page
  }
end


Then /^Logging out redirects me to the Log In page$/ do
  Preconditions %{
    * A project exists in the system
  }

  steps %{
    * Ensure that a user with username #{ bob_logout_username } and password #{ bob_password } has a role of System Admin
    * Register the user named #{ bob_logout_username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_logout_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button
    * Current page should be the Monitoring page
    * Click the Logout button
    * Current page should be the Login page
  }
end


Then /^Logging out clears my session$/ do
  Preconditions %{
    * A project exists in the system
  }

  steps %{
    * Ensure that a user with username #{ bob_logout_username } and password #{ bob_password } has a role of System Admin
    * Register the user named #{ bob_logout_username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_logout_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button
    * Current page should be the Monitoring page
    * Click the Logout button
    * Visit the Projects page
    * Current page should be the Login page
  }
end
