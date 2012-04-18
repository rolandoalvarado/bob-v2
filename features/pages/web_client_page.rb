Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = ConfigFile.web_client_url

# Base class inherited by other pages
class WebClientPage < PO::Page

  def click_log_out
    find_by_xpath("//a[@href='/logout']").click
  end

  def is_secure_page?
    has_xpath?("//a[@href='/logout']")
  end

end