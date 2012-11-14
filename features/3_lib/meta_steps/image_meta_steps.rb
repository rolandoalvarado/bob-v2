Step /^Ensure that the image named (.+) does not exist$/ do |image_name|
  ImageService.session.ensure_image_does_not_exist(@project, name: image_name)
end

Step /^Ensure that the image named (.+) exists for project (.+)$/ do |image_name, project_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  image = ImageService.session.create_image(
            name: image_name, owner: project.id,
            disk_format: 'ami', container_format: 'ami',
            copy_from: test_image_url('ami')
          )
  raise "Image #{ image_name } couldn't be found!" unless image

  @image = image
end

Step /^Register the image named (.+) for deletion at exit$/i do |name|
  image = ImageService.session.images.reload.find { |p| p.name == name }
  EnvironmentCleaner.register(:image, image.id) if image
end
