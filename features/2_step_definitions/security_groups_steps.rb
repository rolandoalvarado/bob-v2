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

Given /^the security group has an attributes of (.+), (.+)$/ do |name, description|
  steps %{
    * Ensure that a security group name #{ name } exists
    * And a security group description #{ description }
    * Raise an error if a security group does not have a name of #{ name }
  }
end

Given /^the project has only one security group named Web Servers$/ do
  steps %{
    * Ensure that a security group named Web Servers exist
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
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password }
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

When /^I add the following rule: (.+), (.+), (.+), (.+), (.+)$/ do |protocol, from_port, to_port, source_type, source|
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab link
    * Current page should have the security groups

    * Click the modify button for security group #{ @new_security_group.id }
    * Current page should have the security group rules form
    * Choose the #{protocol} in the ip protocol dropdown
    * Fill in the from port field with #{from_port}
    * Fill in the to port field with #{to_port}
    * Ensure that a #{source_type} is Subnet
    * Fill in the source field with #{source}
    * Click the add link
  }
end

#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate a security group in the project$/ do

  security_group = CloudObjectBuilder.attributes_for(:security_group, :name => Unique.name('Web Server'))

  ComputeService.session.ensure_security_group_does_not_exist(@project, security_group)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab link
    * Click the new security button
    * Current page should have the new security form
    * Fill in the security group name field with #{security_group.name}
    * Fill in the security group description field with #{security_group.description}
    * Click the create security button    
    * Current page should have the new #{security_group.name} security group
    * The #{security_group.name} security group row should be visible
  }
end

Then /^I [Cc]annot [Cc]reate a security group in the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password }
    * Click the login button

    * Visit the projects page
    * The #{ @project.name } project should not be visible
  }
end

Then /^the security group will be [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab link
    * Current page should have the new security group
  }
end

Then /^the security group will be [Nn]ot [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab link
    * Current page should not have the new security group
  }
end

Then /^The (.+) security group should be visible$/ do |security_group|
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab link
    * Current page should have the new #{security_group.name} security group
  }
end

Then /^Current page should have the new (.+) security group$/ do |security_group|
  steps %{
    * The #{security_group} security group row should be visible
  }
end

Then /^The (.+) security group row should be visible$/ do |security_group|
  steps %{
    * Ensure that #{security_group} security group exist
  }
end

Then /^the security group with attributes (.+), (.+) will be [Cc]reated$/ do |name, description|
  
  security_group = CloudObjectBuilder.attributes_for(
                    :security_group,
                    :name     => Unique.name(name),
                    :description    => description
                  )

  ComputeService.session.ensure_security_group_does_not_exist(@project, security_group)
  
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab link
    * Click the new security button
    * Current page should have the new security form
    * Fill in the security group name field with #{security_group.name}
    * Fill in the security group description field with #{security_group.description}
    * Click the create security button    
    * Current page should have the new #{security_group.name} security group
    * The #{security_group.name} security group row should be visible
  }
end

Then /^the security group with attributes (.+), (.+) will be [Nn]ot [Cc]reated$/ do |name, description|
  
  security_group = CloudObjectBuilder.attributes_for(
                    :security_group,
                    :name     => Unique.name(name),
                    :description    => description
                  )
  
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @user.name }
    * Fill in the password field with #{ @user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab link
    * Click the new security button
    * Current page should have the new security form
    * Fill in the security group name field with #{security_group.name}
    * Fill in the security group description field with #{security_group.description}
    * Click the create security button    
    * The new security form should be visible
    * The new security form error message should be visible
  }
end

#Then /^Choose the (.+) in the ip protocol dropdown$/ do |protocol|
#  steps %{
#    * The #{protocol} protocol should be selected
#  }
#end

#Then /^The (.+) protocol should be selected$/ do |protocol|
#  steps %{
#    * The #{protocol} protocol is selected
#  }
#end

Then /^the rules will be Added$/ do
  steps %{
    * Current page should have the new rules    
  }
end
