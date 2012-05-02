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

    * Click the create instance button
    * Current page should have the create instance form
    * Choose the 1st item in the images list
    * Fill in the server name field with Test Instance
    * Drag the flavor slider 1 position to the right
    * Choose the 1st item in the keypair list
    * Check the 1st security group
    * Click the create instance button

    * Instances list should contain Test Instance
  }
end

Then /^I [Cc]annot [Cc]reate an instance in the project$/ do
  pending
end