#=================
# GIVENs
#=================

Given /^[Aa] project exists in the system$/ do
  steps %{
    * Ensure that a project named Project 1 exists
  }
end

Given /^I have a role of Cloud Admin in the project$/ do
  @username = "admin"
  @password = "klnm12"
  steps %{
    * Click the logout button if currently logged in
    * Visit the Login page
    * Fill in the username field with #{ @username }
    * Fill in the password field with #{ @password }
    * Click the submit button
    * Current page should have the logout button
    * Visit the Projects page 
   }
end

Given /^I have a role of Member in the project$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have a role of \(None\) in the project$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am authorized to create projects$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a user named Arya Stark exists in the system$/ do
  pending # express the regexp above with the code you wish you had
end


#=================
# WHENs
#=================

When /^I create a project with attributes My Awesome Project, Another project$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a project with attributes My Awesome Project, \(None\)$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a project with attributes \(None\), Another project$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a project$/ do
  pending # express the regexp above with the code you wish you had
end


#=================
# THENs
#=================

Then /^I Cannot Create a project$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I Can Create a project$/ do
  project_name = Unique.name("DPBLOG-9-1")
  steps %{
    * Click the create_project button
    * Fill in the project_name field with #{project_name}
    * Fill in the project_description field with "This project is created by cucumber."
    * Click the save_project button
    * Ensure that a project named #{project_name} exists
  }
end

Then /^I can view that project$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^Arya Stark cannot view that project$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the project will be Created$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the project will be Not Created$/ do
  pending # express the regexp above with the code you wish you had
end

