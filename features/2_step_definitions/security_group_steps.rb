#=================
# GIVENs
#=================

Given /^[Tt]he project has no security groups$/ do
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => ('project'))
  EnvironmentCleaner.register(:project, project.id)

  if project.nil? or project.id.empty?
    raise "Project couldn't be initialized!"
  end

  # Make variable(s) available for use in succeeding steps
  @project = project
end

Given /^I am authorized to create a security group in the project$/ do
  step 'I have a role of Member in the project'
end

Given /^the project has only one security group named Web Servers$/ do
  pending # express the regexp above with the code you wish you had
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

    * Fill in the name field with #{name}
    * Fill in the description field with #{description}
    * Click the create security group button
  }

  @security_group_name = name

end

#=================
# THENs
#=================

Then /^I [Cc]an [Cc]reate a security group in the project$/ do
  compute_service = ComputeService.session
  instance        = compute_service.instances.find { |i| i.state == 'ACTIVE' }
  num_security_groups   = compute_service.security_groups.count

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab
    * Click the new security group button
    * Current page should have the new security group form
    * Fill in the name field with #{attrs.name}
    * Fill in the description field with #{attrs.description}
    * Click the create button

    * The security groups table should have #{ num_security_groups + 1 } rows
    * The security groups table's last row should include the text #{ @project.name }
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
    * Click the access security tab
    * Current page should have the new security group
  }
end

Then /^the security group will be [Nn]ot [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * Click the access security tab
    * Current page should not have the new security group
  }
end