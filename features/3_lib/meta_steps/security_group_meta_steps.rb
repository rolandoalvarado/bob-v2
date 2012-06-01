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

Then /^Ensure that a security group named Web Servers exist$/i do
  compute_service = ComputeService.session
  security_group_attrs = CloudObjectBuilder.attributes_for(
                      :security_group,
                      :name     => Unique.name('Web Servers'),
                      :description    => ('Web Servers')
                    )
  new_security_group  = compute_service.create_security_group(@project, security_group_attrs)

  @new_security_group = new_security_group
end


Then /^the rules will be Not Added$/i do
  pending # express the regexp above with the code you wish you had
end

