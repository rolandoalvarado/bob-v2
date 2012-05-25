Then /^[Rr]egister project (.+) for deletion on exit$/ do |name|
  project = IdentityService.session.tenants.reload.find { |p| p.name == name }
  EnvironmentCleaner.register(:project, project.id) if project
end