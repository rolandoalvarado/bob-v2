require_relative '../web_client_page'

class UsersPage < WebClientPage
  validates_path '/users'
end