Then /^Ensure that a test project is available for use$/i do
  identity_service = IdentityService.session
  project          = identity_service.ensure_project_exists(:name => 'project')

  EnvironmentCleaner.register(:project, project.id)

  if project.nil? or project.id.empty?
    raise "Test project couldn't be initialized!"
  end

  @test_project = project
end

Then /^Ensure that I have a role of (.+) in the test project$/i do |role_name|

  if @test_project.nil?
    raise "No test project is available. You need to call " +
          "'* Ensure that a test project is available for use' " +
          "before this step."
  end

  identity_service = IdentityService.session
  user             = @me
  EnvironmentCleaner.register(:user, user.id)

  identity_service.revoke_all_user_roles(user, @test_project)

  # Ensure user has the following role in the project
  unless role_name.downcase == "(none)"
    role = identity_service.roles.find_by_name(RoleNameDictionary.db_name(role_name))

    if role.nil?
      raise "Role #{ role_name } couldn't be found. Make sure it's defined in " +
        "features/support/role_name_dictionary.rb and that it exists in " +
        "#{ ConfigFile.web_client_url }."
    end

    begin
      role.add_to_user(user,@test_project)
    rescue Fog::Identity::OpenStack::NotFound => e
      raise "Couldn't add #{ user.name } to #{ @project.name } as #{ role.name }"
    end
  end
end


Then /^Register project (.+) for deletion on exit$/i do |name|
  project = IdentityService.session.tenants.reload.find { |p| p.name == name }
  EnvironmentCleaner.register(:project, project.id) if project
end