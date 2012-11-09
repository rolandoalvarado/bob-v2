Then /^Ensure that the instance is a member of the (.+) security group$/ do |security_group|
  compute_service = ComputeService.session
  compute_service.ensure_active_instance_count(@project, 1, true, {:security_group => security_group})
end

Step /^Ensure that the instance is a member of the security group$/ do
  compute_service = ComputeService.session
  compute_service.ensure_active_instance_count(@project, 1, true, {:security_group => test_security_group_name })
end

Step /^Ensure that the project named (.+) has an instance named (.+)$/ do |project_name, instance_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  instance = ComputeService.session.create_instance_in_project(project, name: instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  @instance = instance
end


Step /^Ensure that the project named (.+) has an instance with name (.+) and flavor (.+)$/ do |project_name, instance_name, flavor_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  ComputeService.session.create_instance_in_project(project, name: instance_name, flavor: flavor_name)
  instance = ComputeService.session.find_instance_by_name(project, instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance
end


Step /^Ensure that the project named (.+) has an instance with name (.+) and keypair (.+)$/ do |project_name, instance_name, key_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  ComputeService.session.create_instance_in_project(project, name: instance_name, key_name: key_name)
  instance = ComputeService.session.find_instance_by_name(project, instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance
end

Step /^Ensure that the project named (.+) has (?:a|an) (.+) instance named (.+)$/ do |project_name, status, instance_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project
  
  ComputeService.session.create_instance_in_project(project, name: instance_name)
  instance = ComputeService.session.find_instance_by_name(project, instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  if status.upcase == 'PAUSED'
    paused_instance = ComputeService.session.pause_an_instance(project, instance)
    raise "Couldn't ensure #{ instance.name } is in paused state" unless paused_instance
  else
    actual_count = ComputeService.session.send(:"ensure_#{ status }_instance_count", project, 1)
    raise "Couldn't ensure #{ project.name } has 1 #{ status } instance" unless actual_count == 1
  end
end

Step /^Ensure that the project named (.+) has (\d+) (.+) (?:instance|instances)/ do |project_name, desired_count,status |
  desired_count = desired_count.to_i

  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  actual_count = ComputeService.session.send(:"ensure_#{ status }_instance_count", project, desired_count)
  raise "Couldn't ensure #{ project.name } has #{ desired_count } #{ status } instances" unless actual_count == desired_count
end

Step /^Ensure that the project named (.+) has (\d+) (.+) instance (.+)/ do |project_name, desired_count, status, instance_name |
  desired_count = desired_count.to_i

  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  actual_count = ComputeService.session.send(:"ensure_#{ status }_instance_count", project, desired_count)
  raise "Couldn't ensure #{ project.name } has #{ desired_count } #{ status } instances" unless actual_count == desired_count
end

Step /^Ensure that an instance named (.+) does not have any floating IPs$/ do |instance|
  compute_service = ComputeService.session
  compute_service.ensure_project_floating_ip_count(@named_project, 0, instance)
end

Step /^Ensure that the snapshot named (.+) does not exists$/ do |snapshot|
  compute_service = ComputeService.session
  compute_service.ensure_snapshot_does_not_exists(@project, snapshot)
end

Step /^Ensure that an instance has a snapshot named (.+)$/ do |snapshot|
  compute_service = ComputeService.session
  @snapshot = compute_service.ensure_instance_has_a_snapshot(@project, @instance, snapshot)
end

Step /^Ensure that the instance named (.+) has a snapshot named (.+) with visibility (.+) in the project (.+)$/ do |instance_name, snapshot_name, visibility, project_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  compute_service = ComputeService.session
  compute_service.set_tenant project

  instance = compute_service.find_instance_by_name(project, instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  attributes = { name: snapshot_name,
                 visibility: visibility.downcase,
                 credentials: { username: bob_username,
                                password: bob_password } }
  compute_service.ensure_instance_has_a_snapshot(project, instance, attributes)
end
