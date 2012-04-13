require 'capybara'
require 'capybara/dsl'

class WebClientPage
  include CloudConfiguration

  Capybara.run_server = false
  Capybara.current_driver = :selenium
  Capybara.app_host = ConfigFile.web_client_url

  def self.visit
    page = new
    page.visit
    page
  end

  def self.set_path(path)
    send :define_method, :path do
      path
    end
  end

  attr_reader :path

  def initialize
    @session = Capybara.current_session
  end

  #=====================
  # ACTIONS
  #=====================

  def visit
    session.visit path
  end

  def fill_in(field_id, value)
    unless page.has_selector? "##{ field_id }"
      raise "#{ self.class }: Can't find any field with id=#{ field_id }"
    end
    page.fill_in field_id.to_s, :with => value
  end

  def submit
    unless page.has_selector? "#submit"
      raise "#{ self.class }: Can't find a submit button with id=submit"
    end
    page.click_on "submit"
  end

  #=====================
  # QUERIES
  #=====================

  def is_current?
    session.current_path == path
  end

  #=====================
  # ASSERTIONS
  #=====================

  def should_be_current
    unless is_current?
      raise_page_assertion_error "Expected #{ url } but #{ session.current_url } was returned."
    end
  end

  def should_have_content(content)
    unless session.has_content?(content)
      raise_page_assertion_error "#{ self.class } does not contain the content '#{ content }'"
    end
  end

  #=====================
  # OTHERS
  #=====================

  def url
    "#{ session.current_host }#{ path }"
  end

  private

  def page
    @session
  end

  def session
    @session
  end

  def raise_page_assertion_error(message)
    raise PageAssertionError, message
  end
end