# Page Class and Friends
#
# When you subclass Page, the following methods become available to your class:
#
# path(path_to_page)
# ------------------
# declares the expected path of the page
#
# Example: (Assume ConfigFile.web_client_url == http://mc.morphlabs.com)
# ```
#   class LoginPage < Page
#     path '/login'
#   end
#
#   page = LoginPage.new
#   page.expected_path      #=> '/login'
#   page.expected_url       #=> 'http://mc.morphlabs.com/login'
#   page.visit              # visits 'http://mc.morphlabs.com/login'
#   page.actual_path        #=> '/login'
#   page.actual_path        #=> 'http://mc.morphlabs.com/login'
#   page.has_expected_path? #=> true
#   page.has_expected_url?  #=> true
# ```
#
#
# element(name, selector)
# -----------------------
# declares an element that may be found in the html of the page
#
# Parameters:
#
#   name (String) - An arbitrary name you can give the element. Spaces are allowed.
#
#   selector (String or Hash) - The CSS selector for the element. Optionally, you
#     can supply a Hash object. In the Hash object, you can use the key :css or
#     :xpath. E.g. :css => '#login-form' or :xpath => '//*[@id='login-form']
#
# Example:
# ```
#   class LoginPage < Page
#     element 'username', '#login-form .username'
#   end
#
#   page = LoginPage.new
#   page.visit
#   page.has_username_element?    #=> boolean
#   page.has_no_username_element? #=> boolean
#   page.username_element         #=> if '#username' exists in the html, returns a Node object
# ```
# Alternative keywords: button, field, link, checkbox, form, table, span, element
#
# Supplying additional selector/locator information at runtime:
# Sometimes, part of your css selector or xpath locator can't be determine until
# at runtime. In this case, you can add variable placeholder surrounded by angle
# brackets in your css or xpath string and you can substitute it at runtime.
#
# Example:
# ```
#   class UsersPage < Page
#     button 'edit user', '#user-<user_id> .edit-button'
#   end
#
#   page = UsersPage.new
#   page.visit
#   page.edit_user_button(:user_id => @user.id).click

require 'capybara'
require 'capybara/dsl'
require 'anticipate'


if ConfigFile.capybara_driver == :webkit

  begin
    require 'headless'
    headless = Headless.new
    headless.start
    at_exit do
      headless.destroy
    end
  rescue LoadError
  end

  require 'capybara-webkit'
  Capybara.register_driver :webkit do |app|
    Capybara::Driver::Webkit.new(app, {:ignore_ssl_errors => true} )
  end

  # Added to make capybara-webkit run faster. { defaul_value => true }
  Capybara.automatic_reload = false
end

if ConfigFile.capybara_driver == :poltergeist
  require 'capybara/poltergeist'

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {:phantomjs => (ENV['PHANTOMJS_PATH'] || "/usr/local/bin/phantomjs"), :debug => (ENV['POLTERGEIST_DEBUG'] || false)})
  end
end

# Added this for testing Chrome Browser
if ConfigFile.chrome == true
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end

puts "Driver: #{ConfigFile.capybara_driver}"

Capybara.default_driver = ConfigFile.capybara_driver
Capybara.javascript_driver = ConfigFile.capybara_driver

Capybara.run_server = false
Capybara.app_host = ConfigFile.web_client_url

# NOTE: Total waiting time will be NODE_QUERY_WAIT_TIME * MAX_NODE_QUERY_RETRIES
# You want to avoid raising the total waiting time beyond 30 seconds or the
# tests will slow down to a crawl. Play around with the time between retries
# instead, but always be mindful that the total waiting time doesn't get too
# high or you'll be pulling your hair waiting for your tests to finish
NODE_QUERY_WAIT_TIME       = ConfigFile.wait_node
MAX_NODE_QUERY_RETRIES     = ConfigFile.repeat_node
Capybara.default_wait_time = 0    # OLD_VALUE: 0 Don't change this value unless you know the purpose

module NodeMethods
  include Anticipate

  #=====================
  # ACTIONS
  #=====================

  def find(selector)
    n = retry_before_failing { self.node.find selector }
    Node.new(n)
  end

  def find_by_xpath(selector)
    n = retry_before_failing { self.node.find :xpath, selector }
    Node.new(n)
  end

  #=====================
  # QUERIES
  #=====================

  def has_css_selector?(selector)
    self.node.has_selector? selector
  end

  def has_no_css_selector?(selector)
    self.node.has_no_selector? selector
  end

  def has_content?(content)
    self.node.has_content? content
  end

  def has_no_content?(content)
    self.node.has_no_text? content
  end

  def has_xpath?(selector)
    self.node.has_xpath? selector
  end

  def has_no_xpath?(selector)
    self.node.has_no_xpath? selector
  end

  #=====================
  # EXPERIMENTAL
  #=====================

  def wait_for_content_to_disappear(content)
    retry_before_returning_false { self.node.has_no_text? content }
  end

  #=====================
  # PRIVATE
  #=====================

  private

  # This method keeps executing the block called by yield
  # until the block stops raising an error OR until x tries
  def retry_before_failing
    sleeping(NODE_QUERY_WAIT_TIME).seconds.between_tries.failing_after(MAX_NODE_QUERY_RETRIES).tries do
      yield
    end
    yield
  end

  def retry_before_returning_false
    begin
      retry_before_failing { raise 'e' unless yield }
    rescue
      return false
    end
    return true
  end

  def node
    raise "NodeMethods#node must be defined by the class."
  end

end


class Page
  include NodeMethods

  ELEMENT_TYPES    = 'button|field|link|checkbox|form|table|span|element|row|cell|option|message|tab|tile|graph'
  RADIO_LIST_TYPES = 'radiolist'
  CHECK_LIST_TYPES = 'checklist'
  SELECTION_TYPES  = 'selection|dropdown'

  #=====================
  # CLASS METHODS
  #=====================

  def self.path(path)
    send :define_method, :path do
      path
    end
  end

  def self.method_missing(name, *args, &block)
    element   = /^(?<type>#{ ELEMENT_TYPES    })$/.match(name)
    radiolist = /^(?<type>#{ RADIO_LIST_TYPES })$/.match(name)
    checklist = /^(?<type>#{ CHECK_LIST_TYPES })$/.match(name)
    selection = /^(?<type>#{ SELECTION_TYPES  })$/.match(name)

    unless element || radiolist || checklist || selection
      super(name, *args, &block)
    end

    element_name = args[0].split.join('_').downcase

    if element
      register_element   element_name, element['type'], args[1]
    elsif radiolist
      register_radiolist element_name, radiolist['type'], args[1]
    elsif checklist
      register_checklist element_name, checklist['type'], args[1]
    elsif selection
      register_selection element_name, selection['type'], args[1]
    end
  end

  def self.register_element(name, type, options)
    if options.class == Hash && options.has_key?(:xpath)
      send :define_method, "#{ name }_#{ type }" do |vars = {}|
        selector = options[:xpath].clone
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        find_by_xpath selector
      end

      send :define_method, "has_#{ name }_#{ type }?" do |vars = {}|
        selector = options[:xpath].clone
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        has_xpath? selector
      end

      send :define_method, "has_no_#{ name }_#{ type }?" do |vars = {}|
        selector = options[:xpath].clone
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        has_no_xpath? selector
      end
    elsif options.class == String || (options.class == Hash && options.has_key?(:css))
      send :define_method, "#{ name }_#{ type }" do |vars = {}|
        selector = (options.class == String ? options : options[:css]).clone
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        find selector
      end

      send :define_method, "has_#{ name }_#{ type }?" do |vars = {}|
        selector = (options.class == String ? options : options[:css]).clone
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        has_css_selector? selector
      end

      send :define_method, "has_no_#{ name }_#{ type }?" do |vars = {}|
        selector = (options.class == String ? options : options[:css]).clone
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        has_no_css_selector? selector
      end
    else
      raise "Invalid element selector #{ selector.inspect }"
    end
  end

  def self.register_radiolist(name, type, options)
    if options.class == Hash && options.has_key?(:xpath)
      send :define_method, "#{ name }_#{ type }" do
        selector = options[:xpath].clone
        find_by_xpath selector
      end
    elsif options.class == String || (options.class == Hash && options.has_key?(:css))
      send :define_method, "#{ name }_#{ type }" do
        selector = (options.class == String ? options : options[:css]).clone
        find selector
      end
    else
      raise "Invalid radiolist selector #{ selector.inspect }"
    end

    send :define_method, "#{ name }_#{ type }_items" do
      send("#{ name }_#{ type }").all(:xpath, "//input[@type='radio']")
    end
  end

  def self.register_checklist(name, type, options)
    if options.class == Hash && options.has_key?(:xpath)
      send :define_method, "#{ name }_#{ type }" do
        selector = options[:xpath].clone
        find_by_xpath selector
      end
    elsif selector = (options.class == String ? options : options[:css])
      send :define_method, "#{ name }_#{ type }" do
        selector = (options.class == String ? options : options[:css]).clone
        find selector
      end
    else
      raise "Invalid checklist selector #{ selector.inspect }"
    end

    send :define_method, "#{ name }_#{ type }_items" do
      send("#{ name }_#{ type }").all(:xpath, "//input[@type='checkbox']")
    end
  end

  def self.register_selection(name, type, options)
    if options.class == Hash && options.has_key?(:xpath)
      send :define_method, "#{ name }_#{ type }" do
        selector = options[:xpath].clone
        find_by_xpath selector
      end
    elsif selector = (options.class == String ? options : options[:css])
      send :define_method, "#{ name }_#{ type }" do
        selector = (options.class == String ? options : options[:css]).clone
        find selector
      end
    else
      raise "Invalid selection selector #{ selector.inspect }"
    end

    send :define_method, "#{ name }_#{ type }_items" do
      send("#{ name }_#{ type }").all(:xpath, './/option')
    end
  end

  attr_reader :path, :session

  def initialize
    @session = Capybara.current_session
  end

  def node
    session
  end

  #=====================
  # ACTIONS
  #=====================

  def visit
    session.visit path
  end

  #=====================
  # QUERIES
  #=====================

  def has_expected_path?
    retry_before_returning_false { expected_path == actual_path }
  end

  def has_expected_url?
    retry_before_returning_false { expected_url == actual_url }
  end

  def has_popup_window?(selector)
    driver = session.driver
    driver.respond_to?(:find_window) && driver.find_window(selector) rescue false
  end

  #=====================
  # OTHERS
  #=====================

  def expected_path
    path
  end

  def actual_path
    session.current_path
  end

  def expected_url
    "#{ session.current_host }#{ expected_path }"
  end

  def actual_url
    "#{ session.current_host }#{ actual_path }"
  end

  #=====================
  # METHOD MISSING
  #=====================

  def method_missing(name, *args, &block)
    query_without_question_mark  = /^has_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })$/.match(name)
    element_query  = /^has_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })\??$/.match(name)
    element_find   = /^(?<name>.+)_(?<type>#{ ELEMENT_TYPES })$/.match(name)
    element_action = /^(?<action>click|fill_in|select|check)_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })/.match(name)

    if element_action
      raise "Undefined method '#{ element_action[0] }'. Maybe you mean " +
            "#{ self.class }##{ element_action['name'] }_#{ element_action['type'] }.#{ element_action['action'] }?"
    elsif query_without_question_mark
      q = query_without_question_mark
      raise "#{ self.class} doesn't have a method named has_#{ q['name'] }_#{ q['type'] }. " +
            "Try using 'has_#{ q['name'] }_#{ q['type'] }?' (with a trailing question mark) instead."
    elsif element_query
      raise_missing_element_declaration_error(element_query['name'], element_query['type'])
    elsif element_find
      raise_missing_element_declaration_error(element_find['name'], element_find['type'])
    else
      super name, args, block
    end
  end

  def raise_missing_element_declaration_error(element_name, element_type)
    raise "I don't know how to find the #{ element_name } #{ element_type }. " +
          "Make sure you define it by adding \"#{ element_type } '#{ element_name.gsub('_', ' ') }', " +
          "<css_selector>\" in #{ self.class }"
  end
end


class Node
  include NodeMethods

  attr_reader :node

  def initialize(capybara_node)
    @node = capybara_node
  end

  def method_missing(name, *args, &block)
    node.send(name, *args, &block)
  end

end

# ------------------------------------------------------------------------------
# Fix for: StaleElementReferenceError and Webkit::NodeNotAttachedError
# Overried node.find method
Capybara::Selenium::Node.module_eval do
  include Capybara::DSL
  
  # Override node.click method.
  def click
    retry_block do
      if ConfigFile.capybara_driver == :webkit
        native.click
        wait_for_ajax
        wait_for_dom
      else
        resynchronize { native.click }
      end
    end
  end
  
  # Override node.find method.
  def find(locator)
    retry_block do
      wait_for_ajax
      native.find_elements(:xpath, locator).map { |n| self.class.new(driver, n) }
    end
  end
  
end

# Retry block for node.find method above.
def retry_block(n = MAX_NODE_QUERY_RETRIES, &block)
  begin
    block.call
  rescue Selenium::WebDriver::Error::StaleElementReferenceError, Capybara::TimeoutError, Capybara::ElementNotFound, Selenium::WebDriver::Error::UnknownError, Capybara::Driver::Webkit::NodeNotAttachedError
    if (n -= 1) >= 0
      sleep(30 / (n + 1))
      retry
    else
      raise
    end
  end
end

# Integrate these 2 method if you are having problem with built-in node methods.
# Especially with Selenium::WebDriver::Errors, Capybara::Driver::Webkit::Errors
def wait_for_ajax(timeout = NODE_QUERY_WAIT_TIME)
  self.wait_until(timeout) do
    self.evaluate_script 'jQuery.active == 0'
  end
end

def wait_for_dom(timeout = NODE_QUERY_WAIT_TIME)
  uuid = SecureRandom.uuid
  self.evaluate_script <<-EOS
    _.defer(function() {
      $('body').append("<div id='#{uuid}'></div>");
    });
  EOS
  self.first("div", "##{uuid}")
end
# --------------------- END OF FIX ----------------------------------------
