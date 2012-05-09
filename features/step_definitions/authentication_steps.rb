#=================
# GIVENs
#=================

Given /^I am logged in$/ do
  username = 'rstark'
  password = 'asdf123'

  steps %{
    * Click the logout button if currently logged in
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Visit the Login page
    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the login button
    * Current page should have the logout button
  }
end

Given /^I am not logged in$/ do
  steps %{
    * Click the logout button if currently logged in
  }
end

#=================
# WHENs
#=================

When /^I login with the following credentials: (.*), (.*)$/ do |username, password|
  steps %{
    * Visit the login page
    * Current page should have the correct path
    * Current page should have the username field
    * Current page should have the password field
    * Current page should have the login button

    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the login button
  }
end

When /^I logout$/ do
  steps %{
    * Click the logout button
  }
end

When /^I try to access the (.+) section$/ do |section_name|
  steps %{
    * Visit the #{ section_name } page
  }
end


#=================
# THENs
#=================

Then /^I can log out$/ do
  steps %{
    * Current page should have the logout button
    * Click the logout button
    * Current page should be the login page
  }
end

Then /^I will be asked to log in first$/ do
  steps %{
    * Current page should be the login page
  }
end

Then /^I will be [Ll]ogged [Ii]n$/ do
  steps %{
    * Current page should have the logout button
  }
end

Then /^I will be [Nn]ot [Ll]ogged [Ii]n$/ do
  steps %{
    * Current page should be the login page
    * Current page should have the username field
    * Current page should have the password field
    * Current page should have the login button
  }
end

Then /^I will see the (.+) section$/ do |section_name|
  steps %{
    * Current page should be the #{ section_name } page
  }
end
