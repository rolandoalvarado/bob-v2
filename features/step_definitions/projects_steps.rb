#=================
# GIVENs
#=================

Given /^[Aa] project exists in the system$/ do
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => 'Test Project')

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


Given /^The project has (\d+) instances?$/ do |number_of_instances|
  number_of_instances = number_of_instances.to_i
  compute_service     = ComputeService.session
  total_instances     = compute_service.ensure_project_instance_count(@project, number_of_instances)
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
      @project.grant_user_role(user.id, role.id)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user
end

Given /^I have a role of (.+) in the system$/ do |role_name|
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('rstark')
                     )
  identity_service = IdentityService.session

  user             = identity_service.ensure_user_exists(user_attrs)

  project = identity_service.tenants.find { |t| t.name == 'admin' }
  if project.nil? or project.id.empty?
    raise "Project couldn't be found!"
  end

  # Ensure user has the following role in the system
  if role_name.downcase == "(none)"
    # This section is still under observation
    pending
  end

  role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))
  if role.nil?
    raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
      "features/support/role_name_dictionary.rb and that it exists in " +
      "#{ ConfigFile.web_client_url }."
  end

  begin
    project.grant_user_role(user.id, role.id)
  rescue Fog::Identity::OpenStack::NotFound => e
    raise "Couldn't add #{ user.name } to #{ project.name } as #{ role.name }"
  end

  # Make variable(s) available for use in succeeding steps
  @current_user = user
end

Given /^I am authorized to create projects$/ do
  steps %{
    * I have a role of Admin in the system
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

  IdentityService.session.delete_tenant(attrs)

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

  # Make the project name available to subsequent steps
  @project_attrs = attrs
end

When /^I create a project$/ do
  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name => Unique.name('project')
          )

  IdentityService.session.delete_tenant(attrs)

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

  # Make the project name available to subsequent steps
  @project_attrs = attrs
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
            :name => Unique.name('project')
          )

  IdentityService.session.delete_tenant(attrs)

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

  @project_attrs = attrs
end


Then /^I can view that project$/ do
  steps %{
    * Visit the projects page
    * The #{ @project_attrs.name } project should be visible
  }
end


Then /^Arya Stark cannot view that project$/ do
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('aryastark')
                     )
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

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
  if !@current_page.has_new_project_name_error_span? &&
     !@current_page.has_new_project_description_error_span?
    raise ("The project should not have been created, but it seems that it was.")
  end
end