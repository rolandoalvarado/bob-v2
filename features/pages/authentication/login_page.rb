require_relative '../web_client_page'

class LoginPage < WebClientPage
  validates_path '/'

  validates_selector '#username'
  validates_selector '#password'

  submit_button_or_link_selector '#submit'
end