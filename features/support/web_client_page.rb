Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = ConfigFile.web_client_url

class WebClientPage < PO::Page
  logout_button xpath: "//a[@href='/logout']"
end
