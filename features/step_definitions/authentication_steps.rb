# This step definition is not very well designed.
# To improve it, the test should have a secret access
# to the backend that allows it to create the user
# on the fly.
Given /^The following user exists:$/ do |table|
  # credentials = table.hashes[0]
  #
  # visit('/')
  # fill_in 'username', :with => credentials['Username']
  # fill_in 'password', :with => credentials['Password']
  # click_button 'submit'
  #
  # logged_in?.should be_true
  #
  # click_link 'Logout' # Ensure that we start with a new session in subsequent steps of the scenario
end

When /^s?he logs in with the following credentials: (.*), (.*)$/ do |username, password|
  visit('/')
  fill_in 'username', :with => username
  fill_in 'password', :with => password
  click_button 'submit'
end

Then /^s?he will be redirected to (.+)$/ do |page|
  page = "" if page == "login"

  current_path.should == "/#{page}"
end