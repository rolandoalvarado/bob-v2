# This step definition is not very well designed.
# To improve it, the test should have a secret access
# to the backend that allows it to create the user
# on the fly.
Given /^The following user exists:$/ do |table|
  credentials = table.hashes[0]
  @user = {}
  @user[:username] = credentials['Username']
  @user[:password] = credentials['Password']

  # Need something here to ensure that the user actually
  # exists in the system. Ideally, a direct connection
  # to the backend server where we can create the user.
end

Given /^s?he is logged in$/ do
  visit('/')
  fill_in 'username', :with => @user[:username]
  fill_in 'password', :with => @user[:password]
  click_button 'submit'
end

When /^s?he logs in with the following credentials: (.*), (.*)$/ do |username, password|
  visit('/')
  fill_in 'username', :with => username
  fill_in 'password', :with => password
  click_button 'submit'
end

When /^s?he visits the log in page$/ do
  visit ('/')
end

When /^s?he attempts to access (.+) without logging in first/ do |page|
  visit("/#{page}")
end

Then /^s?he will be redirected to the (.+) page$/ do |page|
  page = "" if page == "login" || page == "log in"

  current_path.should == "/#{page}"
end