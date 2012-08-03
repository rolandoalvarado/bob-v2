Then /^Ensure that the instance is a member of the (.+) security group$/ do |security_group|
  compute_service = ComputeService.session
  compute_service.ensure_active_instance_count(@project, 1, true, {:security_group => security_group})
end


Step /^Ensure that the project named (.+) has an instance named (.+)$/ do |project_name, instance_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  instance = ComputeService.session.create_instance_in_project(project, name: instance_name)
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

  instance = ComputeService.session.create_instance_in_project(project, name: instance_name)
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
  compute_service.ensure_project_does_not_have_floating_ip(@named_project, 0, instance)
end
