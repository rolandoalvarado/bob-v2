require_relative '../web_client_page'

class LoginPage < WebClientPage
  path '/'

  field   'Username',    '#username'
  field   'Password',    '#password'

  button  'Login',       '#submit'

  message 'Login Error', '.alert-error'
end
