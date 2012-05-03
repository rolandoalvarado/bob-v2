require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = ConfigFile.web_client_url
Capybara.default_wait_time = 10

class Page

  ELEMENT_TYPES    = 'button|field|link|checkbox|form|table'
  RADIO_LIST_TYPES = 'radiolist'
  CHECK_LIST_TYPES = 'checklist'

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

    if element
      register_element args[0].split.join('_').downcase, element['type'], args[1]
    elsif radiolist
      register_radiolist args[0].split.join('_').downcase, radiolist['type'], args[1]
    elsif checklist
      register_checklist args[0].split.join('_').downcase, checklist['type'], args[1]
    else
      super name, args, block
    end
  end

  def self.register_element(name, type, options)
    if options.class == Hash && options.has_key?(:xpath)
      send :define_method, "#{ name }_#{ type }" do |vars = {}|
        selector = options[:xpath]
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        find_by_xpath selector
      end

      send :define_method, "has_#{ name }_#{ type }?" do |vars = {}|
        selector = options[:xpath]
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        has_xpath? selector
      end
    elsif options.class == String || (options.class == Hash && options.has_key?(:css))
      send :define_method, "#{ name }_#{ type }" do |vars = {}|
        selector = (options.class == String ? options : options[:css])
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        find selector
      end

      send :define_method, "has_#{ name }_#{ type }?" do |vars = {}|
        selector = (options.class == String ? options : options[:css])
        vars.each { |k, v| selector.gsub!("<#{ k }>", v) }
        has_css_selector? selector
      end
    else
      raise "Invalid element selector #{ selector.inspect }"
    end
  end

  def self.register_radiolist(name, type, options)
    if options.class == Hash && options.has_key?(:xpath)
      send :define_method, "#{ name }_#{ type }" do
        selector = options[:xpath]
        find_by_xpath selector
      end
    elsif options.class == String || (options.class == Hash && options.has_key?(:css))
      send :define_method, "#{ name }_#{ type }" do
        selector = (options.class == String ? options : options[:css])
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
        selector = options[:xpath]
        find_by_xpath selector
      end
    elsif selector = (options.class == String ? options : options[:css])
      send :define_method, "#{ name }_#{ type }" do
        selector = (options.class == String ? options : options[:css])
        find selector
      end
    else
      raise "Invalid checklist selector #{ selector.inspect }"
    end

    send :define_method, "#{ name }_#{ type }_items" do
      send("#{ name }_#{ type }").all(:xpath, "//input[@type='checkbox']")
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

  def find(selector)
    session.find(selector)
  end

  def find_by_xpath(selector)
    session.find(:xpath, selector)
  end

  #=====================
  # QUERIES
  #=====================

  def has_expected_path?
    expected_path == actual_path
  end

  def has_expected_url?
    expected_url == actual_url
  end

  def has_css_selector?(selector)
    session.has_selector? selector.to_s
  end

  def has_content?(content)
    session.has_content? content
  end

  def has_xpath?(selector)
    session.has_xpath? selector
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
    element_query  = /^has_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })\??$/.match(name)
    element_find   = /^(?<name>.+)_(?<type>#{ ELEMENT_TYPES })$/.match(name)
    element_action = /^(?<action>click|fill_in|select|check)_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })/.match(name)

    if element_action
      raise "Undefined method '#{ element_action[0] }'. Maybe you mean " +
            "#{ self.class }##{ element_action['name'] }_#{ element_action['type'] }.#{ element_action['action'] }?"
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
          "Make sure you define it by adding \"#{ element_type } '#{ element_name }'" +
          "<css_selector>\" in #{ self.class }"
  end

  #=====================
  # PRIVATE METHODS
  #=====================

  private

  def session
    @session
  end
end