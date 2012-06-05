Step /^Ensure that the instance named (.+) has an attached volume named (.+) in the project (.+)$/ do |instance_name, volume_name, project_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  instance = ComputeService.session.find_instance_by_name(project, instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  volume = VolumeService.session.find_volume_by_name(project, volume_name)
  raise "Volume #{ volume_name } couldn't be found!" unless volume

  ComputeService.session.attach_volume_to_instance_in_project(project, instance, volume)
end


Step /^Ensure that the instance named (.+) has (\d+) attached volumes? in the project (.+)$/ do |instance_name, desired_count, project_name|
  desired_count = desired_count.to_i

  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  instance = ComputeService.session.find_instance_by_name(project, instance_name)
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  actual_count = ComputeService.session.ensure_instance_attached_volume_count(project, instance, desired_count)
  raise "Couldn't ensure #{ instance.name } has #{ desired_count } attached volumes" unless actual_count == desired_count
end


Step /^Ensure that the project named (.+) has (\d+) (?:volume|volumes)$/ do |project_name, desired_count|
  desired_count = desired_count.to_i

  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  actual_count = VolumeService.session.ensure_volume_count(project, desired_count)
  raise "Couldn't ensure #{ project.name } had #{ desired_count } volumes" unless actual_count == desired_count
end


Step /^Ensure that the project named (.+) has a volume named (.+)$/ do |project_name, volume_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  VolumeService.session.create_volume_in_project(project, :name => volume_name)
end

Step /^Ensure that the volume named (.+) is attached to the (\d+)(?:st|nd|rd|th) instace of the project named (.+)$/ do |volume_name, nth_instance, project_name|
  index = nth_instance.to_i - 1
  project = IdentityService.session.find_project_by_name(project_name)
  raise "Project #{ project_name } couldn't be found!" unless project

  instance = ComputeService.session.get_project_instances(project)[index]

  volume = VolumeService.session.find_volume_by_name(project, volume_name)
  rase "Volume #{ volume_name } couldn't be found!" if volume.nil?

  ComputeService.session.attach_volume_to_instance_in_project project, instance, volume
end