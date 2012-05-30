Then /^Ensure that (.+) security group exist$/i do |security_group|
  compute_service = ComputeService.session
  security_group  = compute_service.find_security_group_by_name(@project, security_group)

  if security_group
    compute_service.ensure_project_security_group_count(@project, security_group.count)  
  else
    raise "Security Group couldn't be found!"
  end
  
  EnvironmentCleaner.register(:project, @project.id)

  @security_group = security_group
end
