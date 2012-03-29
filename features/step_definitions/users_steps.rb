#=================
# GIVENs
#=================

#=================
# WHENs
#=================

When /^(?:he|she) tries to create a user in (?:his|her) project$/ do
  steps %{
    * visit Users page
    * fill in name with Jheff
    * fill in email with jvicedo@mail.com
    * fill in password with ASDF
    * fill in password-confirmation with ASDF
    * select the second item in the projects drop down
    * click on save
  }
end

When /^(?:he|she) tries to create a user with (.+), (.+), (.+) and (.+)$/ do |name, email, password, password_confirmation|
  steps %{
    * visit User page
    * fill in name with #{name}
    * fill in email with #{email}
    * fill in password with #{password}
    * fill in password-confirmation with #{password_confirmation}
    * select the second item in the projects drop down
    * click on save
  }
end

#=================
# THENs
#=================

Then /^the new user will be created$/ do
  steps %{
    * visit Users page
    * page should have content 'Jheff'
  }
end

Then /^the new user will not be created$/ do
  steps %{
    * visit Users page
    * page should not have content 'Jheff'
  }
end
