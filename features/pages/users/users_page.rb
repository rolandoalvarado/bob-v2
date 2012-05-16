require_relative '../secure_page'

# The page that is displayed when clicking the users link
class UsersPage < WebClientPage
  path '/users'

  # The 'username' cell in the Users table
  element 'user name',             xpath: "//tr[@class='user']/td[text()='<name>']"

  # Toggles the menu of actions for a specific user in the table
  button  'context menu',          xpath: "//tr[@class='user']/td[text()='<name>']/..//a[@class='dropdown-toggle']"

  # The following links appear in the context menu
  link    'disable user',          xpath: "//tr[@class='user']/td[text()='<name>']/..//a[@class='disable']"
  link    'delete user',           xpath: "//tr[@class='user']/td[text()='<name>']/..//a[@class='destroy']"

  # The following buttons appear with the confirmation dialog that appears
  # when you click the delete link of a user.
  button  'confirm user deletion', "a.okay"
  button  'cancel user deletion',  "a.cancel"
end
