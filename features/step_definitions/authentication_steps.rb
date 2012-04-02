#=================
# GIVENs
#=================

Given /^(.+) is logged in$/ do |user|
  steps %{
    * visit the Home page
    * fill in username with the username of #{user}
    * fill in password with the password of #{user}
    * click on login
  }
end

#=================
# WHENs
#=================

WORD = Transform /^(\S+)$/ do |word|
  word
end

STRING = Transform /^(.+)$/ do |string|
  string
end


When /^he logs in with the following credentials: (#{WORD}), (#{STRING})$/ do |username, password|
  pending # express the regexp above with the code you wish you had
end


#=================
# THENs
#=================

Then /^the new user can login$/ do
  steps %{
    * click on logout
    * visit the Home page
    * fill in username with Jheff
    * fill in password with ASDF
    * click on login
    * current page should be the Projects page
  }
end

Then /^the new user cannot login$/ do
  steps %{
    * click on logout
    * visit the Home page
    * fill in username with Jheff
    * fill in password with ASDF
    * click on login
    * page should have content 'Invalid username or password'
    * current page should be the Login page
   }
end
