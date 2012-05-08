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

  user = identity_service.ensure_user_exists(user_attrs)

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
  user_attrs       = CloudObjectBuilder.attributes_for(
                                                       :user,
                                                       :name => Unique.username('aryastark')
                                                       )
  identity_service = IdentityService.session
  user             = identity_service.ensure_user_exists(user_attrs)

  @current_user = user
end



#=================
# WHENs
#=================

When /^I create a project with attributes (.*), (.*)$/ do |pname,pdesc|

  attributes = CloudObjectBuilder.attributes_for(:tenant, :name => pname)
  IdentityService.session.delete_tenant(attributes)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Click the create_project button
    * Fill in the project_name field with #{pname}
    * Fill in the project_description field with #{pdesc}
    * Click the save_project button
  }
  @project_name = pname

end

When /^I create a project$/ do
  steps %{
    * I create a project with attributes Unique.name, "This project is created by cucumber"
  }
end


#=================
# THENs
#=================

Then /^I Cannot Create a project$/ do
  project_name = Unique.name("DPBLOG91N")
  attributes = CloudObjectBuilder.attributes_for(:tenant, :name => project_name)
  IdentityService.session.delete_tenant(attributes)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * the create project button is disabled
  }
end



Then /^I Can Create a project$/ do
  project_name = Unique.name("DPBLOG91")
  attributes = CloudObjectBuilder.attributes_for(:tenant, :name => project_name)
  IdentityService.session.delete_tenant(attributes)

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Click the create_project button
    * Fill in the project_name field with #{project_name}
    * Fill in the project_description field with "This project is created by cucumber."
    * Click the save_project button
  }
end

Then /^A project named (.+) exists$/ do |project_name|
  unless @current_page.has_project_link?( name: project_name )
    raise ("project #{project_name} should exist, but it doesn't! user is #{@current_user.name} ")
  end
end

Then /^A project named (.+) does not exist$/ do |project_name|
  if @current_page.has_project_link?( name: project_name )
    raise ("project #{project_name} should not exist, but it does! user is #{@current_user.name}")
  end
end

Then /^the (.+) button is disabled$/ do |button_name|
  if @current_page.has_content?(button_name)
    raise ("#{button name} button should not exist. but it is.")
  end
end

Then /^I can view that project$/ do
  pending # express the regexp above with the code you wish you had
end



Then /^Arya Stark cannot view that project$/ do
  pending # express the regexp above with the code you wish you had
end



Then /^the project will be Created$/ do
  steps %{
    * Visit the projects page
    * A project named #{@project_name} exists
  }
end

Then /^the project will be Not Created$/ do
  steps %{
    * Visit the projects page
    * A project named #{@project_name} does not exist
 }
end

Then /^I Can Delete the instance$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I Cannot Delete the instance$/ do
  pending # express the regexp above with the code you wish you had
end
