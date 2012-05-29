require_relative '../secure_page'

# The page that is displayed when clicking the users link
class UsersPage < WebClientPage
  path '/users'

  button  'New User',                "#create-user"
  form    'New User',                "#user-form"

  # Elements in the New User form
  field    'Username',                    "#username"
  field    'Email',                       "#email"
  field    'Password',                    "#password"
  dropdown 'Primary Project',             "#project"
  checkbox 'Project Manager',             "#admin"
  button   'Create User',                 "#submit-user"
  element  'New User Form Error Message', "#user-form .error"

  row      'User',                   "#user-item-<user_id>"

  # The 'username' cell in the Users table
  element 'Username',              xpath: "//tr[@class='user']/td[text()='<name>']"

  # Toggles the menu of actions for a specific user in the table
  button  'Context Menu',          xpath: "//tr[@class='user']/td[text()='<name>']/..//a[@class='dropdown-toggle']"

  # The following links appear in the context menu
  link    'Disable User',          xpath: "//tr[@class='user']/td[text()='<name>']/..//a[@class='disable']"
  link    'Delete User',           xpath: "//tr[@class='user']/td[text()='<name>']/..//a[@class='destroy']"

  # The following buttons appear with the confirmation dialog that appears
  # when you click the delete link of a user.
  button  'Confirm User Deletion', "a.okay"
  button  'Cancel User Deletion',  "a.cancel"
end