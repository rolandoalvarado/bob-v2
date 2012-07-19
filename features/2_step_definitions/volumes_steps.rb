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

Given /^The volume has (\d+) saved snapshots?$/ do |number_of_snapshots|
  number_of_snapshots = number_of_snapshots.to_i
  volume_service      = VolumeService.session
  volume_service.set_tenant @project
  volume              = volume_service.volumes.last
  total_snapshots     = volume_service.ensure_volume_snapshot_count(@project, volume, number_of_snapshots)
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
  compute_service = ComputeService.session
  compute_service.set_tenant @project

  # We need to ensure that there is a floating IP so we can connect to it via SSH later
  compute_service.ensure_project_floating_ip_count(@project, 1, instance)
  floating_ip = compute_service.addresses.find { |a| a.instance_id == instance.id }
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

    * Click the access security tab
    * Fetch a list of device files on the instance with floating IP #{ floating_ip.id }

    * Click the instances and volumes tab
    * Click the attach volume button for volume #{ @volume['id'] }
    * Current page should have the attach volume form
    * Choose the 2nd item in the attachable instance dropdown
    * Click the confirm volume attachment button

    * Click the access security tab
    * A new device file should have been created on the instance with floating IP #{ floating_ip.id }
  }
end

Then /^I can attach the volume to the instance$/i do
  compute_service.ensure_instance_attached_volume_count(@project, @instance, 0)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the attach volume button for volume #{ @volume['id'] }
    * Current page should have the attach volume form
    * Choose the 2nd item in the attachable instance dropdown
    * Click the confirm volume attachment button

    * The volume #{ @volume['id'] } should be attached to instance #{ @instance.name }
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

    * Click the snapshots tab
    * The volume snapshots table should include the text #{ snapshot.name }
  }
end

Then /^I [Cc]an [Dd]elete a snapshot of the volume$/ do
  volume_service = VolumeService.session
  volume_service.set_tenant @project
  snapshot       = volume_service.snapshots.last

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the snapshots tab
    * Click the volume snapshot menu button for volume snapshot named #{ snapshot['display_name'] }
    * Click the delete volume snapshot button for volume snapshot named #{ snapshot['display_name'] }
    * Click the confirm volume snapshot deletion button
    * The volume snapshots table should not include the text #{ snapshot['display_name'] }
  }
end

Then /^I can detach the volume from the instance$/i do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the detach volume button for volume #{ @volume['id'] }
    * Click the confirm volume detachment button

    * The volume #{ @volume['id'] } should not be attached to instance #{ @instance.name }
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


TestCase /^A user with a role of (.+) in a project can attach any of its volumes$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the user with credentials #{ bob_username }/#{ bob_password } has a keypair named #{ test_keypair_name }
    * Ensure that a security group rule exists for project #{ test_project_name }
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the project named #{ test_project_name } has a volume named #{ test_volume_name }
    * Ensure that an instance named #{ test_instance_name } does not have any floating IPs
    * Ensure that the volume named #{ test_volume_name } is not attached to the instance named #{ test_instance_name } in the project #{ test_project_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * The volume named #{ test_volume_name } should be in available status
    * Click the attach button of the volume named #{ test_volume_name }
    * Current page should have the attach volume form
    * Choose the item with text #{ test_instance_name } in the attachable instance dropdown
    * Click the volume attach confirmation button

    * The volume named #{ test_volume_name } should be attached to the instance named #{ test_instance_name } in project #{ test_project_name }
  }

end


TestCase /^A user with a role of (.+) in a project can delete any of its volumes$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a volume named #{ test_volume_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * Click the Context Menu button of the volume named #{ test_volume_name }
    * Click the Delete button of the volume named #{ test_volume_name }
    * Click the Volume Delete confirmation button
    * The Volumes table should have 0 rows
  }

end


TestCase /^A user with a role of (.+) in a project can detach any of its volumes$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the project named #{ test_project_name } has an available volume named #{ test_volume_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * Click the attach button of the volume named #{ test_volume_name }
    * Choose the item with text #{ test_instance_name } in the attachable instance dropdown
    * Click the volume attach confirmation button

    * The volume named #{ test_volume_name } should be attached to the instance named #{ test_instance_name }

    * Click the context menu button of the volume named #{ test_volume_name }
    * Click the detach button of the volume named #{ test_volume_name }
    * Click the volume detach confirmation button

    * The volume named #{ test_volume_name } should not be attached to the instance named #{ test_instance_name } in project #{ test_project_name }
  }

end


TestCase /^A user with a role of (.+) in a project cannot attach any of its volumes$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a volume named #{ test_volume_name }
    * Ensure that the volume named #{ test_volume_name } is not attached to the instance named #{ test_instance_name } in the project #{ test_project_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Visit the projects page
    * The #{ test_project_name } project should not be visible
  }

end


TestCase /^A user with a role of (.+) in a project cannot (?:delete|detach) any of its volumes$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an available volume named #{ test_volume_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Visit the projects page
    * The #{ test_project_name } project should not be visible
  }

end

TestCase /^Volumes that are attached to an instance cannot be deleted$/i do

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the project named #{ test_project_name } has an available volume named #{ test_volume_name }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }

  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project
    * Click the context menu button of the volume named #{ test_volume_name }
    * Click the delete button of the volume named #{ test_volume_name }
    * The delete button of the volume named #{ test_volume_name } should not be visible
  }

end


TestCase /^Volumes that are attached to an instance will be accessible from the instance$/ do

  @time_started = Time.now

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the user #{ bob_username } has a role of Member in the project #{ test_project_name }
    * Ensure that the user with credentials #{ bob_username }/#{ bob_password } has a keypair named #{ test_keypair_name }
    * Ensure that a security group rule exists for project #{ test_project_name }
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the project named #{ test_project_name } has a volume named #{ test_volume_name }
    * Ensure that the volume named #{ test_volume_name } is not attached to the instance named #{ test_instance_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * Click the attach button of the volume named #{ test_volume_name }
    * Current page should have the attach volume form
    * Choose the item with text #{ test_instance_name } in the attachable instance dropdown
    * Click the volume attach confirmation button

    * The volume named #{ test_volume_name } should be attached to the instance named #{ test_instance_name }

    * Click the access security tab
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form
    * Choose the item with text #{ test_instance_name } in the instance dropdown
    * Click the create floating IP allocation button

    * The floating IPs table should have 1 row
    * The floating IP should be associated to instance #{ test_instance_name }

    * A new device file should have been created on the instance named #{ test_instance_name } in project #{ test_project_name }
  }

end
