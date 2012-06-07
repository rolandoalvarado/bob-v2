TestCase /^A user with a role of (.+) in a project can view the statistics of its instances$/i do |role_name|
  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has 1 instance
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Monitoring link
    * Current page should be the Monitoring page
    * There should be 1 tile visible in the page
    * Double-click on the tile for project #{ test_project_name }
    * There should be 1 tile visible in the page
  }
end


TestCase /^A user with a role of (.+) in a project cannot view the statistics of its instances$/i do |role_name|
  Preconditions %{
    * Ensure that a user with username #{ bob_username } and password #{ bob_password } exists
    * Ensure that a project named #{ test_project_name } exists
    * Ensure that the project named #{ test_project_name } has 1 instance
    * Ensure that the user #{ bob_username } has a role of #{ role_name } in the project #{ test_project_name }
  }

  Script %{
    * Click the Logout button if currently logged in
    * Visit the Login page
    * Fill in the Username field with #{ bob_username }
    * Fill in the Password field with #{ bob_password }
    * Click the Login button

    * Click the Monitoring link
    * Current page should be the Monitoring page
    * There should be 0 tiles visible in the page
  }
end

TestCase /^Statistics for (.+) should be visible from the Monitoring page$/ do |resource_type|
  raise "Not yet implemented by mCloud Dashboard"
end