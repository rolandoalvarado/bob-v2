require 'net/ssh'

#=================
# GIVENs
#=================

Given /^I am authorized to (?:assign floating IPs to|create|pause|reboot|resize|resume|suspend|unpause)(?:| an) instances?(?:| in the project)$/ do
  steps %{
    * I have a role of Project Manager in the project
  }
end

Given /^The instance has (\d+) attached volumes?$/ do |number_of_volumes|
  number_of_volumes = number_of_volumes.to_i
  compute_service   = ComputeService.session
  @volume           = compute_service.ensure_instance_attached_volume_count(@project, @instance, number_of_volumes)
end

#=================
# WHENs
#=================

When /^I assign a floating IP to the instance$/ do

  ComputeService.session.set_credentials(@current_user.name, @current_user.password)
  ComputeService.session.ensure_keypair_exists(test_keypair_name)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 10 seconds
    * Click the access security tab
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form
    * Choose the 1st item in the pool dropdown
    * Choose the 2nd item in the instance dropdown
    * Click the create floating IP allocation button
  }

end

When /^I create an instance on that project based on the image (.+)$/ do |image_name|
  compute_service = ComputeService.session
  instance_name = Unique.name('Instance')
  @image_name = image_name

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the new instance button
    * Current page should have the new instance form
    * Click the #{ @image_name } image
    * Fill in the server name field with #{ instance_name }
    * Check the 1st item in the security groups checklist
    * Click the create instance button
  }

  @instance   = compute_service.ensure_project_instance_is_active(@project, instance_name)
end

When /^I pause the instance in the project$/ do
  compute_service = ComputeService.session
  compute_service.service.set_tenant @project
  @instance       = compute_service.instances.find { |i| i.state == 'ACTIVE' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the pause instance button for instance #{ @instance.id }
  }
end

When /^I hard reboot the instance$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the hard reboot instance button for instance #{ @instance.id }
    * Click the confirm instance reboot button
  }
end

When /^I create an instance with attributes (.+), (.+), (.+), (.+) and (.+)$/ do |image,name,flavor,keypair,security_group |

  steps %{
    * Click the Logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Click the Projects link
    * Click the #{ @project.name } project

    * Click the new instance button
    * Current page should have the new instance form

    * Select OS image #{ image } item from the images radiolist
    * Set instance name field with #{ name }
    * Drag the flavor slider to the #{ flavor }
    * Select keypair #{ keypair } item from the keypair dropdown
    * Select Security Group #{ security_group } item from the security group checklist
    * Click the create instance button
  }

  @instance_name  = name
end

When /^I soft reboot the instance$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the soft reboot instance button for instance #{ @instance.id }
    * Click the confirm instance reboot button
  }
end

When /^I resize the instance to a different flavor$/ do
  compute_service = ComputeService.session
  @instance       = compute_service.instances.find { |i| i.state == 'ACTIVE' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * The instance #{ @instance.id } should be in active status

    * Click the resize action in the instance menu for instance #{ @instance.id }

    * Drag the instance flavor slider to a different flavor
    * Click the resize instance confirmation button

    * The instance #{ @instance.id } should be in resizing status
    * The instance #{ @instance.id } should be performing task resize_prep

    * Wait for 5 minutes for resizing to finish
    * The instance #{ @instance.id } should be in active status
    * The instance #{ @instance.id } should be performing task resize_verify

    * Click the confirm resize action in the instance menu for instance #{ @instance.id }
  }
end

When /^I resume the instance in the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the resume instance button for instance #{ @instance.id }
  }
end

When /^I suspend the instance in the project$/ do
  compute_service = ComputeService.session
  compute_service.service.set_tenant @project
  @instance       = compute_service.instances.find { |i| i.state == 'SUSPENDED' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the suspend instance button for instance #{ @instance.id }
  }
end

When /^I unpause the instance in the project$/ do
  compute_service = ComputeService.session
  compute_service.service.set_tenant @project
  @instance       = compute_service.instances.find { |i| i.state == 'PAUSED' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the unpause instance button for instance #{ @instance.id }
  }
end

#=================
# THENs
#=================

Then /^I [Cc]an [Aa]ssign a floating IP to an instance in the project$/ do

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Wait #{ConfigFile.wait_seconds} seconds
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form
    * Wait #{ConfigFile.wait_createinstance} seconds
    * Choose the 1st item in the pool dropdown
    * Choose the 2nd item in the instance dropdown
    * Click the create floating IP allocation button

    * The floating IPs table's last row should include the text #{ @instance.name }
  }
end

Then /^I [Cc]annot [Aa]ssign a floating IP to an instance in the project$/ do
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

Then /^I can connect to that instance via (.+)/ do |remote_client|
  compute_service = ComputeService.session
  compute_service.ensure_project_floating_ip_count(@project, 1, @instance)
  compute_service.ensure_security_group_rule @project
  compute_service.set_tenant @project

  floating_ip = compute_service.addresses.find { |a| a.instance_id == @instance.id }
  raise "Couldn't find a floating IP associated with instance #{ @instance.name }!" unless floating_ip

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab
    * Connect to #{ @image_name } instance with floating IP #{ floating_ip.id } via SSH
  }
end

Then /^I cannot connect to that instance via (.+)/ do |remote_client|
  compute_service = ComputeService.session
  compute_service.ensure_project_floating_ip_count(@project, 1, @instance)
  compute_service.ensure_security_group_rule @project

  floating_ip = compute_service.addresses.find { |a| a.instance_id == @instance.id }
  raise "Couldn't find a floating IP associated with instance #{ @instance.name }!" unless floating_ip

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab
    * Fail connecting to #{ @image_name } instance with floating IP #{ floating_ip.id } via SSH
  }
end

Then /^I [Cc]an [Cc]reate an instance in the project$/ do
  
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the new instance button
    * Current page should have the new instance form
    * Choose the 1st item in the images radiolist
    * Fill in the server name field with #{ test_instance_name }
    * Check the 1st item in the security groups checklist
    * Click the create instance button

    * Current page should have the instance password form
    * Close the instance password form

    * The instances table should include the text #{ test_instance_name }
    * The instance named #{ test_instance_name } should be in active status
  }
  
end

Then /^I [Cc]an [Pp]ause the instances?(?:| in the project)$/ do

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the pause instance button for instance #{ @instance.id }

    * The instance #{ @instance.id } should be of paused status
  }

end

Then /^I [Cc]an [Rr]eboot an instance in the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the soft reboot instance button for instance #{ @instance.id }
    * Click the confirm instance reboot button

    * The instance named #{ @instance.name } should be performing task rebooting
  }
end

Then /^I [Cc]an [Rr]esize (?:that|the) instance$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = @instance
  old_flavor      = compute_service.flavors.find { |f| f.id == instance.flavor['id'].to_s }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ instance.id }
    * Click the resize instance button for instance #{ instance.id }
    * Current page should have the resize instance form
    * Drag the instance flavor slider to a different flavor
    * Click the resize instance confirmation button

    * The instance #{ instance.id } should be in resizing status
    * The instance #{ instance.id } should be performing task resize_prep

    * Wait #{ConfigFile.wait_restart} seconds

    * The instance #{ instance.id } should be in active status
    * The instance #{ instance.id } should be performing task resize_verify

    * Click the instance menu button for instance #{ instance.id }
    * Click the confirm resize instance button for instance #{ instance.id }

    * The instance #{ instance.id } should not have flavor #{ old_flavor.name }
  }
end

Then /^I [Cc]an [Rr]esume the instance$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the resume instance button for instance #{ @instance.id }

     * Wait #{ConfigFile.minute} seconds
    * The instance #{ @instance.id } should be of active status
  }
end

Then /^I [Cc]an [Ss]uspend (?:an|the) instance(?:| in the project)$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the suspend instance button for instance #{ @instance.id }

    * Wait #{ConfigFile.wait_restart} seconds
    * The instance #{ @instance.id } should be in suspended status
  }

  @paused_instance = @instance

end

Then /^I [Cc]an [Uu]npause (?:that|the) instance$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ @instance.id }
    * Click the unpause instance button for instance #{ @instance.id }

    * The instance #{ @instance.id } should be in active status
  }
end

Then /^I [Cc]an [Vv]iew console output of the instance$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ instance.id }
    * Click the view console output button for instance #{ instance.id }

    * Current page should show the instance's console output
  }
end

Then /^I [Cc]an [Vv]iew the instance's web-based VNC console$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ instance.id }
    * Click the VNC console button for instance #{ instance.id }

    * A new window should show the instance's VNC console
  }
end

Then /^I cannot assign a floating IP to (?:that|the) instance$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form

    * The instance dropdown should not have the item with text #{ @instance.name }
  }
end

Then /^I [Cc]annot (?:[Cc]reate|[Dd]elete|[Rr]eboot|[Pp]ause|[Rr]esume) (?:an|the) instance(?:| in the project)$/ do
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

Then /^the instance is publicly accessible via that floating IP$/ do
  compute_service = ComputeService.session
  compute_service.ensure_security_group_rule @project

  steps %{
    * Connect to the instance named #{@instance.name} in project #{@project} via SSH
  }
end

Then /^the instance should be resized$/i do
  old_flavor = ComputeService.session.flavors.find { |f| f.id == @instance.flavor['id'].to_s }
  steps %{
    * Wait for 5 minutes for resizing to finish
    * The instance #{ @instance.id } should not have flavor #{ old_flavor.name }
  }
end

Then /^the instance will be created$/i do
  
  steps %{
    * Current page should have the instance password form
    * Close the instance password form
    * The instances table should include the text #{ @instance_name }
    * The instance named #{ @instance_name } should be in active status
  }
  
end

Then /^the instance will be not created$/i do
  
  steps %{
    * Current page should still have the new instance form
    * The new instance form has an error message
    * Click the cancel create instance button

    * The instances table should not include the text #{ @instance_name }
  }
  
end

Then /^the instance will reboot$/i do
  steps %{
    * The instance named #{ @instance.name } should be performing task rebooting
  }
end

Then /^the instance should be active$/ do
  steps %{
    * The instance #{ @instance.id } should be of active status
  }
end

Then /^an instance is publicly accessible via SSH$/ do
  steps %{
    * The Floating IPs table should have 1 row
    * The Floating IP should be associated to instance #{ @instance.name }

    * Wait for 5 minutes for floating IP to be associated to the instance
    * Connect to the instance named #{ @instance.name } in project #{ @project.name } via SSH
  }
end

TestCase /^A user with a role of (.+) in the project can assign a floating IP to an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a #{ role_name } named #{ member_username }
    * Ensure that a security group rule exists for project #{ test_project_name }
    * Ensure that the user with credentials #{ member_username }/#{ member_password } has a keypair named #{ test_keypair_name }
    * Ensure that the project named #{ test_project_name } has an instance with name #{ test_instance_name } and keypair #{ test_keypair_name }
    * Ensure that an instance named #{ test_instance_name } does not have any floating IPs
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ member_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ member_username }
    * Fill in the Password field with #{ member_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * Click the Access Security tab
    * Click the New Floating IP Allocation button
    * Current page should have the New Floating IP Allocation form
    * Choose the item with text #{ test_instance_name } in the Instance dropdown
    * Click the Create Floating IP Allocation button

    * The Floating IPs table should have 1 row
    * The Floating IP should be associated to instance #{ test_instance_name }
  }

end

TestCase /^A user with a role of \(None\) in the project cannot assign a floating IP to an instance$/i do

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user named #{ member_username } exists
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ member_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ member_username }
    * Fill in the Password field with #{ member_password }
    * Click the Login button

    * Click the Projects link
    * The #{ test_project_name } project should not be visible
  }
end

TestCase /^A user with a role of (.+) in the project Can Delete an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an active instance named #{ test_instance_name }
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

    * The instance named #{ test_instance_name } should be in active status

    * The context menu for the instance named #{ test_instance_name } should have the delete action
  }

end

TestCase /^A user with a role of (.+) in the project Can Unpause an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a paused instance named #{ test_instance_name }
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

    * Click the context button of instance #{ test_instance_name } in #{ test_project_name }
    * Click the unpause button of instance #{ test_instance_name } in #{ test_project_name }

    * The instance named #{ test_instance_name } should be in active status
  }

end


TestCase /^An authorized user can unpause an instance in the project$/i do

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a paused instance named #{ test_instance_name }
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

    * Click the context button of instance #{ test_instance_name } in #{ test_project_name }
    * Click the unpause button of instance #{ test_instance_name } in #{ test_project_name }

    * The instance named #{ test_instance_name } should be in active status
  }

end


TestCase /^A user with a role of (.+) in the project cannot unpause an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } does not exists
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


TestCase /^An instance created based on the image (.+) is accessible via (.+)$/ do |image_name, remote_client|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a member named #{ member_username }
    * Ensure that the project named #{ test_project_name } has 0 active instances
    * Ensure that the user with credentials #{ bob_username }/#{ bob_password } has a keypair named #{ test_keypair_name }
    * Ensure that a security group rule exists for project #{ test_project_name }
    * Ensure that an instance named #{ test_instance_name } does not have any floating IPs
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

    * Click the new instance button
    * Current page should have the new instance form
    * Click the #{ image_name } image
    * Fill in the server name field with #{ test_instance_name }
    * Choose the item with text #{ test_keypair_name } in the keypair dropdown
    * Check the 1st item in the security groups checklist
    * Fill in the server password field with #{ test_instance_password }
    * Click the create instance button

    * Current page should have the instance password form
    * Close the instance password form

    * The instances table should have 1 row
    * The instances table should include the text #{ test_instance_name }
    * The instance named #{ test_instance_name } should be in active status

    * Click the access security tab
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form
    * Choose the item with text #{ test_instance_name } in the instance dropdown
    * Click the create floating IP allocation button

    * The Floating IPs table should have 1 row
    * The Floating IP should be associated to instance #{ test_instance_name }

    * Connect to the instance named #{ test_instance_name } in project #{ test_project_name } via #{ remote_client }
  }

end

TestCase /^An instance is publicly accessible via its assigned floating IP$/ do

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has a member named #{ member_username }
    * Ensure that a security group rule exists for project #{ test_project_name }
    * Ensure that the user with credentials #{ member_username }/#{ member_password } has a keypair named #{ test_keypair_name }
    * Ensure that the project named #{ test_project_name } has an instance with name #{ test_instance_name } and keypair #{ test_keypair_name }
    * Ensure that an instance named #{ test_instance_name } does not have any floating IPs
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ member_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ member_username }
    * Fill in the Password field with #{ member_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * The instance named #{ test_instance_name } should be in active status

    * Click the Access Security tab
    * Click the New Floating IP Allocation button
    * Current page should have the New Floating IP Allocation form
    * Choose the item with text #{ test_instance_name } in the Instance dropdown
    * Click the Create Floating IP Allocation button

    * The Floating IPs table should have 1 row
    * The Floating IP should be associated to instance #{ test_instance_name }

    * Click the Instances and Volumes tab
    * Click and confirm the hard reboot action in the context menu for the instance named #{ test_instance_name }
    * The instance named #{ test_instance_name } should be performing task rebooting
    * The instance named #{ test_instance_name } should be idle
    * The instance named #{ test_instance_name } should have a public IP

    * Click the Access Security tab
    * Connect to the instance named #{ test_instance_name } in project #{ test_project_name } via SSH
  }

end

TestCase /^A user with a role of (.+) in the project can resize an instance$/i do |role_name|

  original_flavor = 'm1.small'
  new_flavor      = 'm1.medium'

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance with name #{ test_instance_name } and flavor #{ original_flavor }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
    * Register the project named #{ test_project_name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * The instance named #{ test_instance_name } should be in active status

    * The context menu for the instance named #{ test_instance_name } should have the resize action
  }

end

TestCase /^A user with a role of (.+) in the project cannot resize an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * The #{ test_project_name } project should not be visible
  }

end

TestCase /^A user with a role of (.+) in the project can revert a resized instance$/i do |role_name|

  original_flavor = 'm1.small'
  new_flavor      = 'm1.medium'

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance with name #{ test_instance_name } and flavor #{ original_flavor }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
    * Register the project named #{ test_project_name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * Click the resize action in the context menu for an instance named #{ test_instance_name } and flavored #{ original_flavor }

    * Drag the instance flavor slider to the #{ new_flavor }
    * Click the resize instance confirmation button

    * The instance named #{ test_instance_name } should be in resizing status

    * Wait at most 3 minutes until the instance named #{ test_instance_name } is in active status
    * The context menu for the instance named #{ test_instance_name } should have the revert resize action
  }

end

TestCase /^A user with a role of (.+) in the project cannot revert a resized instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * The #{ test_project_name } project should not be visible
  }

end

TestCase /^An instance resized by an authorized user will have a different flavor$/i do

  original_flavor = 'm1.small'
  new_flavor      = 'm1.medium'

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance with name #{ test_instance_name } and flavor #{ original_flavor }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
    * Register the project named #{ test_project_name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * The instance named #{ test_instance_name } should be in active status

    * Click the resize action in the context menu for the instance named #{ test_instance_name }

    * Drag the instance flavor slider to the #{ new_flavor }
    * Click the resize instance confirmation button

    * The instance named #{ test_instance_name } should be in resizing status

    * Wait for a few minutes until the instance named #{ test_instance_name } is in active status
    * Click the confirm resize action in the context menu for the instance named #{ test_instance_name }

    * The instance named #{ test_instance_name } should have flavor #{ new_flavor }
  }

end

TestCase /^An instance that has been resized by an authorized user can be reverted to its original flavor$/ do

  original_flavor = 'm1.small'
  new_flavor      = 'm1.medium'

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance with name #{ test_instance_name } and flavor #{ original_flavor }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the user named #{ bob_username } for deletion at exit
    * Register the project named #{ test_project_name } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project

    * The instance named #{ test_instance_name } should be in active status

    * Click the resize action in the context menu for the instance named #{ test_instance_name }

    * Drag the instance flavor slider to the #{ new_flavor }
    * Click the resize instance confirmation button

    * The instance named #{ test_instance_name } should be in resizing status

    * Wait at most 3 minutes until the instance named #{ test_instance_name } is in active status
    * Click the revert resize action in the context menu for the instance named #{ test_instance_name }

    * The instance named #{ test_instance_name } should have flavor #{ original_flavor }
  }

end

TestCase /^An instance deleted by an authorized user should not be visible$/i do

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an active instance named #{ test_instance_name }
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

    * The instance named #{ test_instance_name } should be in active status

    * Click the delete action in the context menu for the instance named #{ test_instance_name }
    * Click the confirm instance deletion button

    * The instance named #{ test_instance_name } should not be visible
  }

end
