#=================
# GIVENs
#=================

Given /^[Aa] storage node is available for use$/ do
  # TODO: Find a better and more robust way to check for storage node.

  # Check if Nexenta is running and if the volume service is accessible
  begin
    Net::HTTP.get_response(URI("#{ConfigFile.web_client_url}:2999")).code.match(/[23]\d{2}/)
  rescue
    # warn "Nexenta is not accessible!"
  end
  VolumeService.session
end

Given /^I am authorized to create volumes in the project$/ do
  step 'I have a role of Member in the project'
end

#=================
# WHENs
#=================

When /^(?:|I )[Cc]reate a volume(?:| with attributes (\(None\)|[^,]*), (\d+|\(None\))(?:|GB))$/ do |name, size|
  attrs = CloudObjectBuilder.attributes_for(:volume)
  volume_service = VolumeService.session
  volume_service.ensure_volume_count(@project, 0)

  attrs['name'] = name || attrs['name']
  attrs['size'] = size || attrs['size']

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
  }

  @volume_attrs = attrs
end

#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate a volume in the project$/ do
  step 'Create a volume'
  step "The volumes table should include the text #{ @volume_attrs.name }"
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

Then /^the volume will be [Cc]reated$/ do
  step "The volumes table should include the text #{ @volume_attrs.name }"
end

Then /^the volume will be [Nn]ot [Cc]reated$/ do
  # current_page should still have a new volume form
  # new volume form should have the error message "This field is required".
  if(!@current_page.has_new_volume_name_error_span? &&
     !@current_page.has_new_volume_size_error_span?   )
    raise "The volume should not have been created, but it seems that it was."
  end
end
