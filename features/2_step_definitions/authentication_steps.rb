Then /^If my username is (.+) and my password is (.+), I can log in with the following credentials (.+), (.+)$/i do |username, password, typed_username, typed_password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ typed_username }
    * Fill in the password field with #{ typed_password }
    * Click the login button

    * Current page should have the Logout button
  }
end


Then /^If my username is (.+) and my password is (.+), I cannot log in with the following credentials (.+), (.+)$/i do |username, password, typed_username, typed_password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ typed_username }
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
  username = 'rstark'
  password = '123qwe'

  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the #{ page_name } page
    * Current page should be the Login page
    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the Login button
    * Current page should be the #{ page_name } page
  }
end


Then /^Logging out redirects me to the Log In page$/ do
  username = 'rstark'
  password = '123qwe'

  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ username }
    * Fill in the Password field with #{ password }
    * Click the Login button
    * Current page should be the Root page
    * Click the Logout button
    * Current page should be the Login page
  }
end


Then /^Logging out clears my session$/ do
  username = 'rstark'
  password = '123qwe'

  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Register the user named #{ username } for deletion at exit

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ username }
    * Fill in the Password field with #{ password }
    * Click the Login button
    * Current page should be the Root page
    * Click the Logout button
    * Visit the Projects page
    * Current page should be the Login page
  }
end