class LoginPage < WebClientPage
  path '/'

  username_field '#username'
  password_field '#password'

  submit_button  '#submit'
end
