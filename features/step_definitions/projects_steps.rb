
# GIVENs
#=================

Given /^[Aa] project exists in the system$/ do
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => ('project'))
  EnvironmentCleaner.register(:project, project.id)
  if project.nil? or project.id.empty?
    raise "Project couldn't be initialized!"
  end

  # Make variable(s) available for use in succeeding steps
  @project = project
end


Given /^At least (\d+) images? should be available for use in the project$/ do |number_of_images|
  number_of_images = number_of_images.to_i
  image_service    = ImageService.session
  images           = image_service.get_public_images

  if images.count < number_of_images
    raise "Expected at least #{ number_of_images } images but found #{ images.count }"
  end
end

Given /^The project has (\d+) active instances?$/ do |number_of_instances|
  number_of_instances = number_of_instances.to_i
  compute_service     = ComputeService.session
  total_instances     = compute_service.ensure_active_instance_count(@project, number_of_instances)
end

Given /^The project has (\d+) suspended instances?$/ do |number_of_instances|
  number_of_instances = number_of_instances.to_i
  compute_service     = ComputeService.session
  total_instances     = compute_service.ensure_suspended_instance_count(@project, number_of_instances)
end

Given /^The project has more than (\d+) instance flavors?$/ do |number_of_flavors|
  number_of_flavors = number_of_flavors.to_i
  compute_service   = ComputeService.session
  compute_service.service.set_tenant @project

  unless compute_service.flavors.count > number_of_flavors
    raise "Project does not have more than #{ number_of_flavors } flavors."
  end
end

Given /^I have a role of (.+) in the project$/ do |role_name|

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
  EnvironmentCleaner.register(:user, user.id)
  identity_service.revoke_all_user_roles(user, @project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
        "features/support/role_name_dictionary.rb and that it exists in " +
        "#{ ConfigFile.web_client_url }."
    end

    begin
      role.add_to_user(user,@project)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user
end


Given /^I am authorized to create projects$/ do
  steps %{
    * I am a System Admin
  }
end

Given /^I am authorized to delete the project$/ do
  steps %{
    * I am a System Admin
    * I have a role of Project Manager in the project
  }
end

Given /^I am authorized to edit the project$/ do
  steps %{
    * I am a System Admin
    * I have a role of Project Manager in the project
  }
end


Given /^a user named Arya Stark exists in the system$/ do
  # nothing to do.
end

#=================
# WHENs
#=================

When /^I create a project with attributes (.*), (.*)$/ do |name, desc|
  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name        => name.downcase == '(none)' ? name : Unique.name(name),
            :description => desc
          )

  IdentityService.session.ensure_project_does_not_exist(attrs)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Click the create project button
    * Fill in the project name field with #{ attrs.name }
    * Fill in the project description field with #{ attrs.description }
    * Click the save project button
  }

  # Register created project for post-test deletion
  created_project = IdentityService.session.find_project_by_name(attrs.name)
  EnvironmentCleaner.register(:project, created_project.id) if created_project

  # Make the project name available to subsequent steps
  @project_attrs = attrs
end

When /^I edit the project.s attributes to (.*), (.*)$/ do |name, desc|

  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name        => name.downcase == '(none)' ? name : Unique.name(name),
            :description => desc
          )

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Edit the #{@project.name} project
    * Fill in the project name field with #{ attrs.name }
    * Fill in the project description field with #{ attrs.description }
    * Click the modify project button
  }

  # Register created project for post-test deletion
  created_project = IdentityService.session.find_project_by_name(attrs.name)
  EnvironmentCleaner.register(:project, created_project.id) if created_project

  # Make the project name available to subsequent steps
  @project_attrs = attrs

end

When /^I create a project$/ do
  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name => Unique.name('project')
          )

  IdentityService.session.ensure_project_does_not_exist(attrs)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Click the create project button
    * Fill in the project name field with #{ attrs.name }
    * Fill in the project description field with #{ attrs.description }
    * Click the save project button
  }

  # Register created project for post-test deletion
  created_project = IdentityService.session.find_project_by_name(attrs.name)
  EnvironmentCleaner.register(:project, created_project.id) if created_project

  # Make the project name available to subsequent steps
  @project_attrs = attrs
end

When /^I delete the project$/ do

  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible

    * Delete the #{ (@project || @project_attrs).name } project
  }

  # Deleting row in the page is asynchronous. So script has to wait 5 seconds.
  sleep(10)
  step "The #{ (@project || @project_attrs).name } project should not be visible"

end


#=================
# THENs
#=================

Then /^I Cannot Create a project$/ do

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The create project button should be disabled
  }
end


Then /^I Can Create a project$/ do
  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name => Unique.name('projext_x')
          )
  IdentityService.session.ensure_project_does_not_exist(attrs)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Click the create project button
    * Fill in the project name field with #{ attrs.name }
    * Fill in the project description field with #{ attrs.description }
    * Click the save project button

    * Visit the projects page
    * The #{ attrs.name } project should be visible
  }

  # Register created project for post-test deletion
  created_project = IdentityService.session.find_project_by_name(attrs.name)
  EnvironmentCleaner.register(:project, created_project.id) if created_project

  # Make project attributes available to subsequent steps
  @project_attrs = attrs
end


Then /^I [Cc]an [Vv]iew (?:that|the) project$/ do
  steps %{

    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name  } project should be visible
    * Click the #{ (@project || @project_attrs).name } project
  }
end

Then /^I [Cc]annot [Vv]iew (?:that|the) project$/ do
  steps %{

    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should not be visible
  }
end

Then /^I [Cc]an [Dd]elete (?:that|the) project$/ do

  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible

    * Delete the #{ (@project || @project_attrs).name } project
  }

  project =  IdentityService.session.tenants.find_by_name((@project || @project_attrs).name)

  if project != nil && project.id != nil
     raise "Project #{ project.name } should be deleted. but it is"
  end

end

Then /^I [Cc]annot [Dd]elete (?:that|the) project$/ do
  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible
  }

  # Deleting row in the page is asynchronous. So script has to wait 5 seconds.

  if ( @current_page.has_delete_project_link?(name: (@project || @project_attrs).name) )
    raise "The project delete link should not have been created, but it seems that it was."
  end

end

Then /^I [Cc]an [Ee]dit (?:that|the) project$/ do
  steps %{

    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible

    * Edit the #{ (@project || @project_attrs).name } project
    * Fill in the project description field with "editting project"
    * Click the modify project button
  }

end


Then /^I [Cc]annot [Ee]dit (?:that|the) project$/ do

  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible
  }

  if ( @current_page.has_edit_project_link?(name: (@project || @project_attrs).name) )
    raise "The project edit should not have been created, but it seems that it was."
  end

end

Then /^Arya Stark cannot view that project$/ do
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('aryastark')
                     )
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)
  EnvironmentCleaner.register(:user, user.id)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ user.name }
    * Fill in the password field with #{ user.password }
    * Click the login button

    * Visit the projects page
    * The #{ @project_attrs.name } project should not be visible
  }
end


Then /^the project will be [Cc]reated$/ do
  steps %{
    * Visit the projects page
    * The #{ @project_attrs.name } project should be visible
  }
end

Then /^the project will be Not Created$/ do
  # current_page should still have a new project form
  # new project form should have the error message "This field is required".
  if ( !@current_page.has_new_project_name_error_span? && !@current_page.has_new_project_description_error_span? )
    raise "The project should not have been created, but it seems that it was."
  end
end

Then /^the project will be [Uu]pdated$/ do
  steps %{
    * Visit the projects page
    * The #{ @project_attrs.name } project should be visible
  }
end

Then /^the project will be Not Updated$/ do
  # current_page should still have a new project form
  # new project form should have the error message "This field is required".
  if ( !@current_page.has_project_name_error_span? && !@current_page.has_project_description_error_span? )
    raise "The project should not have been created, but it seems that it was."
  end
end

Then /^the project and all its resources will be deleted$/ do
  pending # express the regexp above with the code you wish you had
end
