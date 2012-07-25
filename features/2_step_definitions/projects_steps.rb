#=================
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

Given /^The project has (\d+) (active|paused|suspended) instances?$/ do |number_of_instances, status|
  number_of_instances = number_of_instances.to_i
  compute_service     = ComputeService.session
  compute_service.send("ensure_#{ status }_instance_count", @project, number_of_instances)

  compute_service.set_tenant @project
  instances = compute_service.instances

  if number_of_instances == 1
    @instance = instances.find { |i| i.state == status.upcase }
  else
    @instance = instances.select { |i| i.state == status.upcase }
  end
end

Given /^The project has (\d+) available volumes?$/ do |number_of_volumes|
  number_of_volumes = number_of_volumes.to_i
  volume_service    = VolumeService.session
  total_volumes     = volume_service.ensure_volume_count(@project, number_of_volumes)
end

Given /^[Tt]he project does not have any floating IPs$/ do
  compute_service = ComputeService.session
  compute_service.ensure_project_does_not_have_floating_ip(@project, 0, @instance)
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
                       :name => Unique.username('bob')
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
      role.add_to_user(user, @project)
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

Given /^I am authorized to grant project memberships$/i do
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
            :name        => name.downcase == '(none)' ? name : Unique.project_name(name),
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

When /^I (.*) edit the project's attributes to (.*), (.*)$/i do |can_or_cannot, name, desc|
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page

    * Edit the #{@project} project
  } 

  if name.downcase == "(none)"
    step "Clear the project name field"
  else 
    step "Fill in the project name field with #{ name }"
  end

  if desc.downcase == "(none)"
    step "Clear the project description field"
  else 
    step "Fill in the project description field with #{ desc }"
  end

    step "Click the modify project button"

  if can_or_cannot.downcase == "can"
    step "Visit the projects page"
    step "The #{name} project should be visible"
    @project.save
  else
    if ( !@current_page.has_project_name_error_span? && 
         !@current_page.has_project_description_error_span? )
         raise "The project should not have been created, but it seems that it was."
    end
  end
end

When /^I create a project$/ do
  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name => Unique.project_name('project')
          )

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

  # Deleting row in the page is asynchronous. So script has to wait 10 seconds.
  sleep(10)
  step "The #{ (@project || @project_attrs).name } project should not be visible"

end

When /^I grant project membership to (?:her|him)/i do

  step "I can grant project membership to #{@user.name}"

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

    * Wait 30 seconds
    * Visit the projects page
    * The create project button should be disabled
  }
  
end


Then /^I Can Create a project$/ do
  attrs = CloudObjectBuilder.attributes_for(
            :project,
            :name => Unique.project_name('project')
          )

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

Then /^I can grant project membership to (.+)$/i do |username|
  
  user = @user
  
  steps %{

    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name  } project should be visible
    * Click the #{ (@project || @project_attrs).name } project

    * Click the collaborators tab
    * Click the add collaborator button
    * Click the collaborators tab
    * Click the add collaborator button
    * Fill in the email field with #{ user.email }
    * Click the add collaborator button
    * Current page should have the new collaborator
  }

end

Then /^I cannot grant project membership to (.+)$/i do |username|

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

Then /^I can delete (?:that|the) project$/i do

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
     raise "Project #{ project.name } should be deleted. but it's not"
  end

end


Then /^I failed to delete (?:that|the) project$/i do
  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible
  }

  @current_page.project_menu_button( name: project_name ).click
  @current_page.delete_project_link( name: project_name ).click
  if (!@current_page.has_unable_to_delete_field?) then
    raise "The project deletng should be failed, but it seems to succeeed."
  end

end

Then /^I can edit (?:that|the) project$/i do
  
  project_name = "Edited Project"
  project_description = "Edited Project Description"
  
  steps %{
    * Click the logout button if currently logged in
    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible

    * Edit the #{ (@project || @project_attrs).name } project
    * Fill in the project name field with #{ project_name }
    * Fill in the project description field with #{ project_description }
    * Click the modify project button
    
    * Visit the projects page
    * The #{ project_name } project should be visible
  }
  
  # Register created project for post-test deletion
  edited_project = IdentityService.session.find_project_by_name(project_name)
  EnvironmentCleaner.register(:project, edited_project.id) if edited_project

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


Then /^(?:She|He) can view the project$/ do
  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ @current_user.name }
    * Fill in the password field with #{ @current_user.password }
    * Click the login button

    * Visit the projects page
    * The #{ (@project || @project_attrs).name } project should be visible
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


Then /^the project and all its resources will be deleted$/ do
  pending # express the regexp above with the code you wish you had
end

# Testcases
#=================

TestCase /^A user with a role of (.+) in a project can edit the instance quota of the project$/i do |role_name|
  
  floating_ips  = 10
  volumes       = 10
  cores         = 20

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project
    * Wait 10 seconds
    * Click the quota modify button
    * Current page should have the modify quota form
    * Fill in the floating ips quota edit field with #{ floating_ips }
    * Fill in the volumes quota edit field with #{ volumes }
    * Fill in the cores quota edit field with #{ cores }
    * Click the save quota edit button
    * Quota Values should be updated with #{ floating_ips } , #{ volumes } and #{ cores }
  }


end


TestCase /^A user with a role of (.+) in a project cannot edit the instance quota of the project$/i do |role_name| 
  
  floating_ips  = 10
  volumes       = 10
  cores         = 20

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the user #{ bob_username } has a role of Member in the system
    * Ensure that the user #{ bob_username } has a role of #{role_name} in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }
  
  Script %{

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project
    * Wait 10 seconds
    * The quota modify link should be disabled
  }

end

Then /^I [Cc]annot [Ee]dit (?:that|the) project$/ do
  username      = Unique.username('bob')
  password      = '123qwe'
  project_name  = Unique.project_name('project')

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the user #{ username } has a role of Member in the system
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

    * Visit the projects page
    * The #{ project_name } project should not be visible
  }
end


TestCase /^I cannot delete (?:that|the) project$/i do
  username      = Unique.username('bob')
  password      = '123qwe'
  project_name  = Unique.project_name('project')

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the user #{ username } has a role of Member in the system
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

    * Visit the projects page
    * The #{ project_name } project should not be visible
  }
end



TestCase /^Project can be updated the quota of the project with (.+) , (.+) and (.+)$/i do |floating_ips,volumes,cores|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name } 
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project
    * Wait 10 seconds
    * Click the quota modify button

    * Fill in the floating ips quota edit field with #{ floating_ips }
    * Fill in the volumes quota edit field with #{ volumes }
    * Fill in the cores quota edit field with #{ cores }
    * Click the save quota edit button

    * Quota Values should be updated with #{ floating_ips } , #{ volumes } and #{ cores }

  }

end

TestCase /^Project cannot be updated the quota of the project with (.+) , (.+) and (.+)$/i do |floating_ips,volumes,cores|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Projects link
    * Click the #{ test_project_name } project
    * Wait 10 seconds
    * Click the quota modify button

    * Fill in the floating ips quota edit field with #{ floating_ips }
    * Fill in the volumes quota edit field with #{ volumes }
    * Fill in the cores quota edit field with #{ cores }
    
    * Click the save quota edit button
    * A quota edit dialog show error
  }

end


