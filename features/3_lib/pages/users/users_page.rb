require_relative '../secure_page'

# The page that is displayed when clicking the users hyperlink
class UsersPage < SecurePage
  path '/users'

  button  'New User',                         "#new-user"
  form    'New User',                         "#user-form"
  form    'Edit User',                        "#user-form-modal"

  # Elements in the User form
  field    'Username',                        "#username"
  field    'Email',                           "#email"
  field    'Password',                        "#password"
  dropdown 'Primary Project',                 "#project"
  dropdown 'Role',                            "#project_manager"
  button   'Create User',                     "#create-user"
  button   'Edit User',                       xpath: "//tr[@class='user']/td[normalize-space(text())='<name>']/..//a[@class='edit']"
  button   'Update User',                     "#update-user"
  element  'New User Form Error Message',     "#user-form .error"
  element  'Edit User Form Error Message',    "#user-form .error"
  element  'users',                           "#user-list"

  row       'User',                            xpath: "//*[@id='user-list']//td[normalize-space(text())='<name>']/.."
  hyperlink 'User',                            xpath: "//*[@id='user-list']//td[normalize-space(text())='<name>']"
  checkbox  'admin',                           "#admin"

  # The 'username' cell in the Users table
  element 'Username',                         xpath: "//tr[@class='user']/td[normalize-space(text())='<name>']"

  # Toggles the menu of actions for a specific user in the table
  button  'Context Menu',                     xpath: "//tr[@class='user']/td[normalize-space(text())='<name>']/..//a[@class='dropdown-toggle']"

  # The following hyperlinks appear in the context menu
  hyperlink    'Disable User',                     xpath: "//tr[@class='user']/td[normalize-space(text())='<name>']/..//a[@class='disable']"
  hyperlink    'Delete User',                      xpath: "//tr[@class='user']/td[normalize-space(text())='<name>']/..//a[@class='destroy']"

  hyperlink    'Edit User',                        xpath: "//tr[@class='user']/td[normalize-space(text())='<name>']/..//a[@class='edit']"

  # The following buttons appear with the confirmation dialog that appears
  # when you click the delete hyperlink of a user.
  button  'Confirm User Deletion',            "a.okay"
  button  'Cancel User Deletion',             "a.cancel"
end
