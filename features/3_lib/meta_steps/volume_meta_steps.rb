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