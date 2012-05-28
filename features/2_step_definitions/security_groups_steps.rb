#=================
# GIVENs
#=================

Given /^[Tt]he project has no security groups$/ do
  compute_service = ComputeService.session
  project         = compute_service.ensure_security_group_does_not_exist(:name => ('Web Server'))
  EnvironmentCleaner.register(:project, project.id)
  
  if project.nil? or project.id.empty?
    raise "Project couldn't be initialized!"
  end

  # Make variable(s) available for use in succeeding steps
  @project = project
end

Given /^I am authorized to create a security group in the project$/ do
  steps %{
    'I have a role of Member in the project'  
  }
end

Given /^the project has only one security group named Web Servers$/ do
  steps %{
    'The project has security group Web Servers'
  }
end

#=================
# WHENs
#=================

When /^I create a security group with attributes (.+), (.+)$/ do |name,descripton|

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

    * Fill in the Security Group Name field with #{name}
    * Fill in the Security Group Description field with #{description}
    * Click the create security group button
  }
end

#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate a security group in the project$/ do

  security_group = CloudObjectBuilder.attributes_for(:security_group, :name => Unique.name('Web Server'))

  ComputeService.session.ensure_security_group_does_not_exist(security_group)

  steps %{
    * Click the Logout button if currently logged in

    * Visit the Login page
    * Fill in the Username field with #{ @current_user.name }
    * Fill in the Password field with #{ @current_user.password }
    * Click the Login button

    * Visit the Projects page
    * Click the #{ @project.name } project

    * Click the access Security Tab link
    * Click the New Security button
    * Current page should have the New Security form
    * Fill in the Security Group Name field with #{security_group.name}
    * Fill in the Security Group Description field with #{security_group.description}
    * Click the Create Security button    
    * Current page should have the new security group
    * The #{ security_group.name } security group row should be visible
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

Then /^the security group will be [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab link
    * Current page should have the new security group
  }
end

Then /^The security group will be [Nn]ot [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the #{ @project.name } project
    * Click the access security tab link
    * Current page should not have the new security group
  }
end

Then /^The (.+) security group should be visible$/ do |security_group|
  steps %{
    * Visit the Projects page
    * Click the #{ @project.name } project
    * Click the access Security Tab link
    * Current page should have the new security group.
  }
end

Then /^Current page should have the new security group$/ do
  security_group = CloudObjectBuilder.attributes_for(:security_group, :name => Unique.name('Web Server'))
  
  steps %{
    * The #{security_group.name} security group should be visible
  }
end

