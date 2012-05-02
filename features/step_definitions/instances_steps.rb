#=================
# GIVENs
#=================


#=================
# WHENs
#=================


#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate an instance in the project$/ do
  steps %{
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the new instance button
    * Current page should have the new instance form
    * Choose the 1st item in the images radiolist
    * Fill in the server name field with Test Instance
    * Check the 1st item in the security groups checklist
    * Click the create instance button

    * The #{ @project.name } project should have an instance named Test Instance
  }
end

Then /^I [Cc]annot [Cc]reate an instance in the project$/ do
  pending
end