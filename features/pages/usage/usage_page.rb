require_relative '../web_client_page'

class UsagePage < WebClientPage
  validates_path '/usage'
end