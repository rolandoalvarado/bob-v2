require_relative '../secure_page'

class UsersPage < WebClientPage
  path '/users'

  element 'user name',             xpath:  "//tr[@class='user']/td[text()='<name>']"
  button  'user menu',             xpath:  "//tr[@class='user']/td[text()='<name>']/..//a[@class='dropdown-toggle']"
  link    'delete user',           xpath:  "//tr[@class='user']/td[text()='<name>']/..//a[@class='destroy']"
  button  'delete confirmation',   xpath:  "//*[@class='btn btn-danger okay']"
end
