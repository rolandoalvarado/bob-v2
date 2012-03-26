Given /^The following user exists:$/ do |table|
  @user = table.rows_hash
  ensure_user_exists @user
end

Given /^s?he is logged in$/ do
  visit('/')
  fill_in 'email', :with => @user['Email']
  fill_in 'password', :with => @user['Password']
  click_button 'submit'
end

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

Then /^s?he will be redirected to the (.+) page$/ do |page|
  page = "" if page == "login" || page == "log in"

  current_path.should == "/#{page}"
end