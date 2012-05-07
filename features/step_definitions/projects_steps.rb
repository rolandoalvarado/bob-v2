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

Given /^The project has at least (\d+) images?$/ do |number_of_images|
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
  user_attrs       = CloudObjectBuilder.attributes_for(
                       :user,
                       :name => Unique.username('rstark')
                     )
  identity_service = IdentityService.session

  user = identity_service.ensure_user_exists(user_attrs)

  # Ensure user has no roles in the project
  user.roles(@project.id).each do |role|
    @project.remove_user_role(user.id, role['id'])
  end

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
            "features/support/role_name_dictionary.rb and that it exists in " +
            "#{ ConfigFile.web_client_url }."
    end

    begin
      @project.add_user_role(user.id, role.id)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end

  # Make variable(s) available for use in succeeding steps
  user.password = user_attrs[:password]
  @current_user = user
end

Given /^I am authorized to create projects$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a user named Arya Stark exists in the system$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have a role of (.+) in the system$/ do |role_name|
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => 'admin')

  if project.nil? or project.id.empty?
    raise "Project couldn't be initialized!"
  end

  # Make variable(s) available for use in succeeding steps
  old_project = @project
  @project = project

  steps %{
   * I have a role of #{role_name} in the project
  }

  @project = old_project

end



#=================
# WHENs
#=================

When /^I create a project with attributes My Awesome Project, Another project$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a project with attributes My Awesome Project, \(None\)$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a project with attributes \(None\), Another project$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a project$/ do
  pending # express the regexp above with the code you wish you had
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

    * the create project button is disabled.
  }
end

Then /^I Can Create a project$/ do
  project_name = Unique.name("DPBLOG-9-1")
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
    * A project named #{project_name} exists
  }
end

Then /^A project named (.+) exists$/ do |project_name|

    project =  IdentityService.session.tenants.find_by_name(project_name)
    if project.nil? or project.id.empty?
      raise ("project #{project_name} should exist, but it's not")      
    end

end

Then /^the create project button is disabled\.$/ do
  button = @current_page.find('disabled create project')
  if button.nil?
    raise ("create project button should not exist. but it is.")      	  
  end
end

Then /^I can view that project$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^Arya Stark cannot view that project$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the project will be Created$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the project will be Not Created$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I Can Delete the instance$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I Cannot Delete the instance$/ do
  pending # express the regexp above with the code you wish you had
end
