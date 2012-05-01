require_relative '../web_client_page'

class LoginPage < WebClientPage
  path '/'

  username_field '#username'
  password_field '#password'

  login_button  '#submit'
end
