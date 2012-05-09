require 'net/ssh'

#=================
# GIVENs
#=================

Given /^The project does not have any floating IPs$/ do
  compute_service = ComputeService.session
  compute_service.ensure_project_floating_ip_count(@project, 0)
end

Given /^I am authorized to assign floating IPs to instances in the project$/ do

  if @project.nil?
    raise "No project was defined. You might need to add '* A project exists in the system' " +
          "in the feature file."
  end

  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('rstark')
                     )
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

  identity_service.revoke_all_user_roles(user, @project)

  # Ensure user has the following role in the project
  role = identity_service.roles.find_by_name(RoleNameDictionary.db_name('Project Manager'))

  if role.nil?
    raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
          "features/support/role_name_dictionary.rb and that it exists in " +
          "#{ ConfigFile.web_client_url }."
  end

  begin
    @project.grant_user_role(user.id, role.id)
  rescue Fog::Identity::OpenStack::NotFound => e
    raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user

end

#=================
# WHENs
#=================

When /^I assign a floating IP to the instance$/ do
  compute_service = ComputeService.session
  instance        = compute_service.project_instance(@project)
  @floating       = compute_service.create_floating_ip_in_project(@project, instance)
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
    * Click the login button

    * Visit the projects page
    * Click the #{ @project.name } project

    * Click the access security tab link
    * Click the new floating IP allocation button
    * Current page should have the new floating IP allocation form
    * Choose the 2nd item of the pool dropdown
    * Choose the 2nd item of the instance dropdown
    * Click the create floating IP allocation button
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



Then /^I [Cc]annot [Cc]reate an instance in the project$/ do
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
  begin
    ssh = Net::SSH.start(@floating.ip, 'root', password: 's3l3ct10n')
    ssh.close
  rescue
    raise "The instance is not publicly accessible via floating IP #{ @floating.ip }."
  end
end
