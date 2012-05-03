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

  instance_name = Unique.name('Instance')

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
    * Fill in the server name field with #{ instance_name }
    * Check the 1st item in the security groups checklist
    * Click the create instance button

    * The instances table should include the text #{ instance_name }
  }
end

Then /^I [Cc]annot [Cc]reate an instance in the project$/ do
  pending
end