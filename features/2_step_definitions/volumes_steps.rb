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

Given /^I am authorized to attach volumes to the instance$/ do
  steps %{
    * I have a role of Member in the project
  }
end

Given /^I am authorized to create volumes in the project$/ do
  steps %{
    * I have a role of Member in the project
  }
end


#=================
# WHENs
#=================

When /^I create a volume with attributes (\(None\)|[^,]*), (\d+|\(None\))(?:|GB)$/ do |name, size|
  attrs = CloudObjectBuilder.attributes_for(
    :volume, name: name, size: size)
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
    * Fill in the volume size field with #{ attrs[:size] }
    * Click the create volume button
  }

  @volume_attrs = attrs
end


#=================
# THENs
#=================

Then /^an attached volume will be accessible from the instance$/ do
  volume_service  = VolumeService.session
  volume_service.set_tenant @project
  volume          = volume_service.volumes.first

  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find{ |i| i.state == 'ACTIVE' }
  addresses       = compute_service.addresses

  # We need to ensure that there is a floating IP so we can connect to it via SSH later
  compute_service.ensure_project_floating_ip_count(@project, 1, instance)
  addresses.reload
  floating_ip     = addresses.find{ |a| a.instance_id == instance.id }
  raise "No floating IP associated to instance #{ instance.name }!" unless floating_ip
  compute_service.ensure_security_group_rule @project

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab link
    * Fetch a list of device files on the instance with floating IP #{ floating_ip.id }

    * Click the instances and volumes tab link
    * Click the attach volume button for volume #{ volume['id'] }
    * Current page should have the attach volume form
    * Choose the 2nd item in the attachable instance dropdown
    * Click the confirm volume attachment button

    * Click the access security tab link
    * A new device file should have been created on the instance with floating IP #{ floating_ip.id }
  }
end

Then /^I can attach the volume to the instance$/i do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }

  volume_service  = VolumeService.session
  volume_service.set_tenant @project
  volume          = volume_service.volumes.first

  compute_service.ensure_instance_has_no_attached_volume(@project, instance)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the attach volume button for volume #{ volume['id'] }
    * Current page should have the attach volume form
    * Choose the 2nd item in the attachable instance dropdown
    * Click the confirm volume attachment button

    * The volume #{ volume['id'] } should be attached to instance #{ instance.name }
  }
end

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
    * Fill in the volume size field with #{ attrs[:size] }
    * Click the create volume button
    * The volumes table should include the text #{ attrs.name }
  }

  @volume_attrs = attrs
end

Then /^I [Cc]an [Cc]reate a snapshot of the volume$/ do
  volume_service = VolumeService.session
  volume_service.set_tenant @project
  volume         = volume_service.volumes.last
  volume_service.ensure_volume_snapshot_count(@project, volume, 0)
  snapshot       = CloudObjectBuilder.attributes_for(:snapshot)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the volume menu button for volume #{ volume['id'] }
    * Click the new volume snapshot button for volume #{ volume['id'] }
    * Current page should have the new volume snapshot form
    * Fill in the volume snapshot name field with #{ snapshot.name }
    * Fill in the volume snapshot description field with #{ snapshot.description }
    * Click the create volume snapshot button

    * Click the snapshots tab link
    * The volume snapshots table should include the text #{ snapshot.name }
  }
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
  steps %{
    * The volumes table should include the text #{ @volume_attrs.name }
  }
end

Then /^the volume will be [Nn]ot [Cc]reated$/ do
  steps %{
    * The new volume form error message should be visible
  }
end
