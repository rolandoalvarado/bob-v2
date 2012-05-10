#=================
# GIVENs
#=================

Given /^[Aa] storage node is available for use$/ do
  # TODO: Find a better and more robust way to check for storage node.

  # Check if Nexenta is running and if the volume service is accessible
  Net::HTTP.get_response(URI("#{ConfigFile.web_client_url}:2999")).code.match(/[23]\d{2}/)
  VolumeService.session
end

#=================
# WHENs
#=================

#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate a volume in the project$/ do
  attrs = CloudObjectBuilder.attributes_for(:volume)
  volume_service = VolumeService.session
  volume_service.ensure_volume_count(@project, 0)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the new volume button
    * Current page should have the new volume form
    * Fill in the volume name field with #{ attrs.name }
    * Fill in the volume description field with #{ attrs.description }
    * Fill in the volume size field with #{ attrs.size }
    * Click the create volume button

    * The volumes table should include the text #{ attrs.name }
  }

  @volume_attrs = attrs
end

Then /^I [Cc]annot [Cc]reate a volume in the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ @project.name } project should not be visible
  }
end
