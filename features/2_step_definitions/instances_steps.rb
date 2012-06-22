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
  compute_service = ComputeService.session
  compute_service.service.set_tenant @project

  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }
  addresses       = compute_service.addresses

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
    * Choose the 1st item in the pool dropdown
    * Choose the 2nd item in the instance dropdown
    * Click the create floating IP allocation button

    * The floating IPs table should have #{ addresses.count } rows
    * The floating IPs table's last row should include the text #{ instance.name }
  }

  addresses.reload
  @floating = addresses.find {|a| a.instance_id == instance.id}

  raise "No floating IP associated to instance #{ instance.name }" if @floating.nil?
  
  @instance = instance
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

    * Click the instance menu button for instance #{ @instance.id }
    * Click the hard reboot instance button for instance #{ @instance.id }
    * Click the confirm instance reboot button
  }
end

When /^I create an instance with attributes (.+), (.+), (.+), (.+) and (.+)$/ do |image,name,flavor,keypair,security_group |

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

    * Select OS image #{ image } item from the images radiolist
    * Set instance name field with #{ name }
    * Select flavor #{ flavor } item from the flavor slider
    * Select keypair #{ keypair } item from the keypair dropdown
    * Select Security Group #{ security_group } item from the security group checklist
    * Click the create instance button
  }

  @instance_name = name

end

When /^I soft reboot the instance$/ do
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

    * Click the instance menu button for instance #{ @instance.id }
    * Click the resize instance button for instance #{ @instance.id }
    * Current page should have the resize instance form
    * Drag the instance flavor slider to a different flavor
    * Click the resize instance confirmation button

    * The instance #{ @instance.id } should be in resizing status
    * The instance #{ @instance.id } should be performing task resize_prep

    * The instance #{ @instance.id } should be in active status
    * The instance #{ @instance.id } should be performing task resize_verify

    * Click the instance menu button for instance #{ @instance.id }
    * Click the confirm resize instance button for instance #{ @instance.id }
  }
end

When /^I resume the instance in the project$/ do
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
  compute_service = ComputeService.session
  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }
  num_addresses   = compute_service.addresses.count

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
    * Choose the 1st item in the pool dropdown
    * Choose the 2nd item in the instance dropdown
    * Click the create floating IP allocation button

    * The floating IPs table should have #{ num_addresses } rows
    * The floating IPs table's last row should include the text #{ instance.name }
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

  instance_name = Unique.name('Instance')

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
    * Fill in the server name field with #{ instance_name }
    * Check the 1st item in the security groups checklist
    * Click the create instance button

    * The instances table should include the text #{ instance_name }
  }
end

Then /^I [Cc]an [Dd]elete an instance in the project$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.first

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ instance.id }
    * Click the delete instance button for instance #{ instance.id }
    * Click the confirm instance deletion button
    * The instances table should not include the text #{ instance.name }
  }
end

Then /^I [Cc]an [Pp]ause the instances?(?:| in the project)$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
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

    * The instance #{ @instance.id } should be of paused status
  }
end

Then /^I [Cc]an [Rr]eboot an instance in the project$/ do
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
    * Click the soft reboot instance button for instance #{ instance.id }
    * Click the confirm instance reboot button

    * The instance #{ instance.id } should be shown as rebooting
  }
end

Then /^I [Cc]an [Rr]esize (?:that|the) instance$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }
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

    * The instance #{ instance.id } should be in active status
    * The instance #{ instance.id } should be performing task resize_verify

    * Click the instance menu button for instance #{ instance.id }
    * Click the confirm resize instance button for instance #{ instance.id }

    * The instance #{ instance.id } should not have flavor #{ old_flavor.name }
  }
end

Then /^I [Cc]an [Rr]esume the instance$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find { |i| i.state == 'SUSPENDED' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ instance.id }
    * Click the resume instance button for instance #{ instance.id }

    * The instance #{ instance.id } should be of active status
  }
end

Then /^I [Cc]an [Ss]uspend (?:an|the) instance(?:| in the project)$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
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
    * Click the suspend instance button for instance #{ @instance.id }

    * The instance #{ @instance.id } should be in suspended status
  }
end

Then /^I [Cc]an [Uu]npause (?:that|the) instance$/ do
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  instance        = compute_service.instances.find { |i| i.state == 'PAUSED' }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the instance menu button for instance #{ instance.id }
    * Click the unpause instance button for instance #{ instance.id }

    * The instance #{ instance.id } should be in active status
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
  compute_service = ComputeService.session
  compute_service.set_tenant @project
  addresses       = compute_service.addresses

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

    * Click the create floating IP allocation button

    * The floating IPs table should have #{ addresses.count + 1 } rows
    * The floating IPs table's last row should not include the text #{ @instance.name }
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
  remote_client = 'SSH'
  
  steps %{
    * Connect to the instance named #{@instance.name} in project #{@project} via #{remote_client}
  }
end

Then /^the instance should be resized$/i do
  old_flavor = ComputeService.session.flavors.find { |f| f.id == @instance.flavor['id'].to_s }
  steps %{
    * The instance #{ @instance.id } should not have flavor #{ old_flavor.name }
  }
end

Then /^the instance will reboot$/i do
  steps %{
    * The instance #{ @instance.id } should be shown as rebooting
  }
end


TestCase /^An instance created based on the image (.+) is accessible via (.+)$/ do |image_name, remote_client|

  username      = Unique.username('bob')
  password      = '123qwe'
  project_name  = Unique.project_name('test')
  instance_name = Unique.instance_name('test')

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the project named #{ project_name } has 0 active instances
    * Ensure that the user #{ username } has a role of Member in the project #{ project_name }
    * Ensure that a security group rule exists for project #{ project_name }
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ username } for deletion at exit
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ username }
    * Fill in the Password field with #{ password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ project_name } project

    * Click the new instance button
    * Current page should have the new instance form
    * Click the #{ image_name } image
    * Fill in the server name field with #{ instance_name }
    * Check the 1st item in the security groups checklist
    * Click the create instance button

    * The instances table should have 1 row
    * The instances table should include the text #{ instance_name }
    * The instance named #{ instance_name } should be in active status

    * Click the access security tab
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form
    * Choose the item with text #{ instance_name } in the instance dropdown
    * Click the create floating IP allocation button

    * The floating IPs table should have 1 row
    * The floating IP should be associated to instance #{ instance_name }

    * Connect to the instance named #{ instance_name } in project #{ project_name } via #{ remote_client }
  }

end
