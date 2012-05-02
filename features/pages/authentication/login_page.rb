require_relative '../web_client_page'

class LoginPage < WebClientPage
  path '/'

  field  'username', '#username'
  field  'password', '#password'

  button 'login',    '#submit'
end
