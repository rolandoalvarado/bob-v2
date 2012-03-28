#=================
# GIVENs
#=================

Given /^The following user exists:$/ do |table|
  @user = table.hashes
  ensure_user_exists @user
end

Given /^s?he is logged in$/ do
  visit('/')
  fill_in 'email', :with => @user['Email']
  fill_in 'password', :with => @user['Password']
  click_button 'submit'
end

Given /^(.+) is logged in$/ do |user|
  steps %{
    visit Home page
    fill in username with username of #{user}
    fill in password with password of #{user}
    click on login 
  }
end

#=================
# WHENs
#=================

When /^s?he logs in with the following credentials: (.*), (.*)$/ do |email, password|
  visit('/')
  fill_in 'email', :with => email
  fill_in 'password', :with => password
  click_button 'submit'
end

When /^s?he visits the log in page$/ do
  visit ('/')
end

When /^s?he attempts to access (.+) without logging in first/ do |page|
  visit("/#{page}")
end

#=================
# THENs
#=================

Then /^s?he will be redirected to the (.+) page$/ do |page|
  page = "" if page == "login" || page == "log in"

  current_path.should == "/#{page}"
end

Then /^the new user can login$/ do 
  steps %{
    click on logout
    visit Home page
    fill in username with Jheff
    fill in password with ASDF
    click on login
    current path should ‘/projects’
  }
end

Then /^the new user cannot login$/ do
  steps %{
    click on logout
    visit Home page
    fill in username with Jheff
    fill in password with ASDF
    click on login
    the system will display ‘Invalid username or password’
    current path should be ‘/’
   }
end
