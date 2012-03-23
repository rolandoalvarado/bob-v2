Given /^The following user exists:$/ do |table|
  credentials = table.hashes[0]

  visit('/')
  fill_in 'username', :with => credentials['Username']
  fill_in 'password', :with => credentials['Password']
  click_button 'submit'
  logged_in?.should be_true
end