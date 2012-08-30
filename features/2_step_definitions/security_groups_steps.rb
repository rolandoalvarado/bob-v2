#=================
# GIVENs
#=================

Given /^I am a? (Project Manager|Member)$/ do |role_name|
  steps %{
    * Ensure that I have a role of #{ role_name } in the project
  }
end

Given /^I am authorized to create a security group in the project$/ do
  steps %{
    * Ensure that I have a role of Project Manager in the project
  }
end

Given /^the project has no security groups$/ do
  steps %{
    * Ensure that the project has no security groups
  }
end

Given /^the project has a security group$/ do
  steps %{
    * Ensure that the project has a security group
  }
end

Given /^the security group has an attributes of (.+), (.+)$/ do |name, description|
  steps %{
    * Ensure that a security group named #{ name } exists
    * And a security group description #{ description }
    * Raise an error if a security group does not have a name of #{ name }
  }
end

Given /^the project has only one security group named Web Servers$/ do
  steps %{
    * Ensure that a security group named Web Servers exist
  }
end

Given /^The project has an instance that is a member of the (.+) security group$/ do |security_group|
  steps %{
    * Ensure that the instance is a member of the #{security_group} security group
  }
end

Given /^I am authorized to edit a security group in the project$/ do
  role_name = 'Project Manager'

  steps %{
    * Ensure that I have a role of #{ role_name } in the project
  }
end

Given /^I am authorized to delete security groups in the project$/ do
  role_name = 'Project Manager'

  steps %{
    * Ensure that I have a role of #{ role_name } in the project
  }
end

Given /^the instance is a member of the (.+) security group$/ do |security_group|
  steps %{
    * Ensure that the instance is a member of the #{security_group} security group
  }
end

#=================
# WHENs
#=================

When /^I create a security group with attributes (.+), (.+)$/ do |name, description|
    
  security_group = CloudObjectBuilder.attributes_for(:security_group, :name => Unique.name(name))

  ComputeService.session.ensure_security_group_does_not_exist(@project, security_group)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the new security group button
    * Current page should have the new securiy group form

    * Fill in the security group name field with #{security_group.name}
    * Fill in the security group description field with #{security_group.description}
    * Click the create security group button
  }
end


When /^I edit a security group with the following rule: (.+), (.+), (.+), (\d+\.\d+\.\d+\.\d+(?:|\/\d+)|\(None\)|\(Random\))$/ do |protocol, from_port, to_port, cidr|

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait #{ConfigFile.wait_seconds} seconds
    * Click the access security tab

    * Wait #{ConfigFile.wait_seconds} seconds
    * Current page should have the security groups

    * Click the edit security group button for security group #{ @security_group.id }
    * Current page should have the security group rules form

    * Click the new security group rule button
    * Current page should have the new security group rule form
    * Choose the item with text Custom in the service dropdown
    * Choose the item with text #{ protocol } in the ip protocol dropdown
    * Set the from port field to #{ from_port }
    * Set the to port field to #{ to_port }
    * Fill in the CIDR field with #{ cidr }
    * Click the add security group rule button
  }

end

When /^I add the following rule: (.+), (.+), (.+), (\d+\.\d+\.\d+\.\d+(?:|\/\d+)|\(None\)|\(Random\))$/ do |protocol, from_port, to_port, cidr|

  compute_service = ComputeService.session

  attrs           = CloudObjectBuilder.attributes_for(
                    :security_group,
                    :name => Unique.name('Web Servers'),
                    :description => 'Web Servers Security Group'
                  )

  security_group  = compute_service.ensure_security_group_exists(@project, attrs)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab

    * Wait 2 seconds

    * Current page should have the security groups

    * Click the edit security group button for security group #{ security_group.id }
    * Current page should have the security group rules form

    * Click the new security group rule button
    * Current page should have the new security group rule form
    * Choose the item with text Custom in the service dropdown
    * Choose the item with text #{ protocol } in the ip protocol dropdown
    * Set the from port field to #{ from_port }
    * Set the to port field to #{ to_port }
    * Fill in the CIDR field with #{ cidr }
    * Click the add security group rule button
  }

end

#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate a security group in the project$/ do

  security_group = CloudObjectBuilder.attributes_for(:security_group, :name => Unique.name('Web Servers'))

  ComputeService.session.ensure_security_group_does_not_exist(@project, security_group)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Click the new security group button
    * Current page should have the new security form
    * Fill in the security group name field with #{security_group.name}
    * Fill in the security group description field with #{security_group.description}
    * Click the create security button

    * Wait 1 second

    * Current page should have the new #{security_group.name} security group
    * The #{security_group.name} security group row should be visible
  }
end

Then /^I [Cc]an [Ee]dit a security group in the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait #{ConfigFile.wait_seconds} seconds

    * Click the access security tab
    * Current page should have the security groups

    * Click the edit security group button for security group #{ @security_group.id }
    * Current page should have the security group rules form

    * Click the new security group rule button
    * Current page should have the new security group rule form
    * Choose the item with text Custom in the service dropdown
    * Choose the item with text (Any) in the ip protocol dropdown
    * Set the from port field to (Random)
    * Set the to port field to (Random)
    * Fill in the CIDR field with 0.0.0.0/25
    * Click the add security group rule button

    * Current page should have the new security group rule
  }
end

Then /^I [Cc]an Delete the Web Servers security group in the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Click the context menu button for security group #{ @new_security_group.id }
    * Click the delete security group button for security group #{ @new_security_group.id }
    * Click the confirm security group deletion button
    * The #{@new_security_group.name} security group should not be visible
  }
end

Then /^I [Cc]annot [Cc]reate a security group in the project$/ do
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

Then /^I [Cc]annot [Ee]dit a security group in the project$/ do
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

Then /^I Cannot Delete the Web Servers security group in the project$/ do
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

Then /^I Cannot Delete the (.+) security group$/ do |sec_group|
  compute_service = ComputeService.session
  compute_service.set_tenant(@project)
  security_groups = compute_service.security_groups
  security_groups.each do |sg|
    if(sg.name.match Regexp.new(sec_group))
      @delete_security_group = sg
    end
  end

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Click the context menu button for security group #{ @delete_security_group.id }
    * Click the delete security group button for security group #{ @delete_security_group.id }
    * Click the confirm security group deletion button
    * The #{@delete_security_group.name} security group row should be visible
  }
end

Then /^the security group will be [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Current page should have the new security group
  }
end

Then /^the security group will be [Nn]ot [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab
    * Current page should not have the new security group
  }
end

Then /^The (.+) security group should be visible$/ do |security_group|
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Current page should have the new #{security_group.name} security group
  }
end

Then /^The (.+) security group row should be visible$/ do |security_group|
  steps %{
    * Ensure that #{security_group} security group exist
  }
end

Then /^The (.+) security group should not be visible$/ do |security_group|
  steps %{
    * Ensure that #{security_group} security group does not exist
  }
end

Then /^the security group with attributes (.+), (.+) will be [Cc]reated$/ do |name, description|
  
  security_group = CloudObjectBuilder.attributes_for(
                    :security_group,
                    :name     => Unique.name(name),
                    :description    => description
                  )

  @security_group = ComputeService.session.ensure_security_group_does_not_exist(@project, security_group)
  
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Click the new security group button
    * Current page should have the new security form
    * Fill in the security group name field with #{security_group.name}
    * Fill in the security group description field with #{security_group.description}
    * Click the create security button

    * Wait 1 second

    * Current page should have the new #{security_group.name} security group
    * The #{security_group.name} security group row should be visible
  }
end

Then /^the security group with attributes (.+), (.+) will be [Nn]ot [Cc]reated$/ do |name, description|
  
  @security_group = CloudObjectBuilder.attributes_for(
                    :security_group,
                    :name     => Unique.name(name),
                    :description    => description
                  )
  
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Wait 2 seconds

    * Click the access security tab
    * Click the new security group button
    * Current page should have the new security form
    * Fill in the security group name field with #{name}
    * Fill in the security group description field with #{description}
    * Click the create security button

    * Wait 1 second

    * The new security form should be visible
    * The new security group form error message should be visible
  }
end

Then /^the rules will be Added$/ do
  steps %{
    * Current page should have the new rules
  }
end

Then /^the rule will be [Aa]dded$/ do
  steps %{
    * Current page should have the new security group rule
  }
end

Then /^the rule will be [Nn]ot [Aa]dded$/ do
  steps %{
    * The add security group rule button should be disabled
    * Current page should still have the new security group rule form
  }
end
