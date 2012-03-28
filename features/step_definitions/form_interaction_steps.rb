When /^visit '\/'$/ do
  pending # express the regexp above with the code you wish you had
end

When /^(?:he|she) tries to create a user in her project$/ do
  steps %{
    visit Users page
    fill in name with Jheff
    fill in email with jvicedo@mail.com
    fill in password ASDF
    fill in password confirmation with ASDF
    select first item in the projects drop down
    click on save
  }
end

When /^(?:he|she) tries to create a user with (.+), (.+), (.+), and (.+)$/ do |name, email, password, password_conf|
  steps %{
    visit User page
    fill in name with #{name}
    fill in email with #{email}
    fill in password with #{password}
    fill in password confirmation with #{password_conf}
    select first item in the projects drop down
    click on save
  } 
end
