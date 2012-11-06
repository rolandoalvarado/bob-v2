TestCase /^A user with a role of (.+) in a project can delete a snapshot$/i do |role_name|

  username     = Unique.username('bob')
  password     = '123qwe'
  project_name = Unique.project_name('project')
  instance_name = Unique.instance_name('instance')
  snapshot_name = Unique.snapshot_name('snapshot')

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the project named #{ project_name } has an instance named #{ instance_name }
    * Ensure that the user #{ username } has a role of #{ role_name } in the project
    * Ensure that the instance named #{ instance_name } has a snapshot named #{ snapshot_name }
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the login button

    * Click the projects link
    * Click the #{ project_name } project

    * Click the access snapshot tab
    * Current page should have the snapshots
    * Click the context menu button for snapshot #{ snapshot_name }
    * Click the delete snapshot button for snapshot #{ snapshot_name }
    * Click the confirm snapshot deletion button
    * The #{ snapshot_name } snapshot should not be visible
  }

end

TestCase /^A user with a role of (.+) in a project can create an image from an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
    * Ensure that the snapshot named #{ test_instance_snapshot_name } does not exists
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the projects link
    * Click the #{ test_project_name } project

    * Click the snapshot action in the context menu for the instance named #{ test_instance_name }
    * Current page should have the new instance snapshot form
    * Fill in the snapshot name field with #{ test_instance_snapshot_name }
    * Click the create instance snapshot button

    * Click the images and snapshots tab
    * The snapshot named #{ test_instance_snapshot_name } should be in active status
  }

end

TestCase /^A user with a role of (.+) in a project cannot create an image from an instance$/i do |role_name|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that no projects exist in the system
    * Ensure that a project named #{ test_project_name } exists
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the projects link
    * The #{ test_project_name } project should not be visible
  }

end

TestCase /^Image that will be created from the instance will have the visibility of (\(Default\)|Private) and should be visible to Project$/i do |visibility|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
    * Ensure that the instance named #{ test_instance_name } has a snapshot named #{ test_instance_snapshot_name } with visibility #{ visibility } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the projects link
    * Click the #{ test_project_name } project

    * Click the images and snapshots tab
    * The snapshot named #{ test_instance_snapshot_name } should not be public
  }

end

TestCase /^Image that will be created from the instance will have the visibility of Public and should be visible to Everyone$/i do

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
    * Ensure that the instance named #{ test_instance_name } has a snapshot named #{ test_instance_snapshot_name } with visibility Public in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the projects link
    * Click the #{ test_project_name } project

    * Click the images and snapshots tab
    * The snapshot named #{ test_instance_snapshot_name } should be public
  }

end

TestCase /^Image that will be created will be written in (.+) format$/i do |format|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
    * Ensure that an instance has a snapshot named #{ test_instance_snapshot_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the projects link
    * Click the #{ test_project_name } project

    * Click the images and snapshots tab
    * The snapshot named #{ test_instance_snapshot_name } should be in #{ format } format
  }

end


TestCase /^A user with a role of (.+) in a project can create an image$/i do |role_name|

  username     = Unique.username('bob')
  password     = '123qwe'
  project_name = Unique.project_name('project')
  instance_name = Unique.instance_name('instance')
  snapshot_name = Unique.snapshot_name('snapshot')

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the project named #{ project_name } has an instance named #{ instance_name }
    * Ensure that the user #{ username } has a role of #{ role_name } in the project
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ username } for deletion at exit
  }

  Script %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the login button

    * Click the projects link
    * Click the #{ project_name } project

    * Click the access snapshot tab
    * Current page should have the snapshots
    * Click the context menu button for snapshot #{ snapshot_name }
    * Click the delete snapshot button for snapshot #{ snapshot_name }
    * Click the confirm snapshot deletion button
    * The #{ snapshot_name } snapshot should not be visible
  }

end


TestCase /^A user with a role of (.+) in a project can delete an image$/i do |role_name|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
    * Ensure that the image named #{ test_image_name } exists for project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the image named #{ test_image_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the images link
    * The context menu for the image named #{ test_image_name } should have the delete action

  }

end


TestCase /^A user with a role of (.+) in a project can import an image$/i do |role_name|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the images link
    * The upload image button should not be disabled

  }

end


TestCase /^A user with a role of (.+) in a project cannot (?:delete|import) an image$/i do |role_name|

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Current page should not have the images link

  }

end


TestCase /^A user with a role of (.+) in a project Cannot Delete a snapshot$/ do |role_name|
  username     = Unique.username('bob')
  password     = '123qwe'
  project_name = Unique.project_name('project')

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the user #{ username } has a role of #{ role_name } in the project
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ username } for deletion at exit
  }

  steps %{
    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the login button

    * Visit the projects page
    * The #{ project_name } project should not be visible
  }

end


TestCase /^An authorized user can import an image with a format of AKI$/ do

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
    * Ensure that the image named #{ test_image_name } does not exist
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the images link
    * Click the upload image button

    * Current page should have the upload image form
    * Fill in the image name field with #{ test_image_name }
    * Choose the item with text aki in the image disk format dropdown
    * Fill in the image url field with #{ test_image_url('aki') }
    * Fill in the AMI url field with #{ test_image_url('ami') }
    * Fill in the ARI url field with #{ test_image_url('ari') }
    * Choose the item with text #{ test_project_name } in the project dropdown
    * Click the confirm upload button

    * The images table should have a row for the image named #{ test_image_name } Kernel Image
    * The images table should have a row for the image named #{ test_image_name } Ramdisk Image
    * The images table should have a row for the image named #{ test_image_name }

    * The image #{ test_image_name } Kernel Image should be in active status
    * The image #{ test_image_name } Ramdisk Image should be in active status
    * The image #{ test_image_name } should be in active status

  }

end


TestCase /^An authorized user can import an image with a format of (?:ARI|AMI)$/ do
  pending
end


TestCase /^An image deleted in the project can no longer be used by that project$/ do

  Preconditions %{
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
    * Ensure that the image named #{ test_image_name } exists for project #{ test_project_name }
  }

  Cleanup %{
    * Register the project named #{ test_project_name } for deletion at exit
    * Register the image named #{ test_image_name } for deletion at exit
    * Register the user named #{ bob_username } for deletion at exit
  }

  Script %{

    * Click the logout button if currently logged in

    * Visit the login page
    * Fill in the username field with #{ bob_username }
    * Fill in the password field with #{ bob_password }
    * Click the login button

    * Click the images link
    * Click and confirm the delete action in the context menu for the image named #{ test_image_name }

    * Click the projects link
    * Click the #{ test_project_name } project

    * Click the new instance button
    * Current page should have the new instance form
    * The images radio list should not have the item #{ test_image_name }

  }

end


TestCase /^Snapshot that are attached to a running instance cannot be deleted$/ do
  username     = Unique.username('bob')
  password     = '123qwe'
  project_name = Unique.project_name('project')
  instance_name = Unique.instance_name('test_instance')
  snapshot_name = Unique.snapshot_name('snap-001')
  role_name     = 'Project Manager'

  Preconditions %{
    * Ensure that a user with username #{ username } and password #{ password } exists
    * Ensure that a project named #{ project_name } exists
    * Ensure that the project named #{ project_name } has an instance named #{ instance_name }
    * Ensure that the instance named #{ instance_name } has a snapshot named #{ snapshot_name }$/
    * Ensure that the user #{ username } has a role of #{ role_name } in the project
  }

  Cleanup %{
    * Register the project named #{ project_name } for deletion at exit
    * Register the user named #{ username } for deletion at exit
  }

  steps %{
    * Visit the login page
    * Fill in the username field with #{ username }
    * Fill in the password field with #{ password }
    * Click the login button

    * Click the projects link
    * Click the #{ project_name } project

    * Click the access snapshot tab
    * Current page should have the snapshots
    * Click the context menu button for snapshot #{ snapshot_name }
    * Click the delete snapshot button for snapshot #{ snapshot_name }
    * Click the confirm snapshot deletion button
    * The snapshot form error message element should be visible
  }
end
