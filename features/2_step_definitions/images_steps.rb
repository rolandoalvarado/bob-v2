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
    * Ensure that the instance named #{ instance_name } has a snapshot named #{ snapshot_name }$/ 
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

    * Click the instance menu button for instance #{ @instance.id }
    * Click the snapshot instance button for instance #{ @instance.id }
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

TestCase /^Image that will be created from the instance will have the visibility of (.+) and should be visible to (.+)$/i do |visibility, visible_to|

  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has an instance named #{ test_instance_name }
    * Ensure that the user #{ bob_username } has a role of Project Manager in the project #{ test_project_name }
    * Ensure that a snapshot named #{ test_instance_snapshot_name } has a visibility of #{ visibility }
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
    * The snapshot named #{ test_instance_snapshot_name } should have the visibility of #{ visibility } 
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
