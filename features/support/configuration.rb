# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'
require 'rubygems'
require 'yaml'
require 'fileutils'

# The reason why we wrap the credentials in this class is so that
# we only need to look at one place to determine what type of cloud we
# are dealing with. While it's highly unlikely that we will change from
# OpenStack to something else in the near future, when the event happens, we
# will be able to easily shift by just changing this one file.

module CloudConfiguration
  PATH                 = File.expand_path('../../support/config.yml', __FILE__)
  WEB_CLIENT_HOST      = :web_client_host
  OPENSTACK_OPTIONS    = :openstack_options
  OPENSTACK_AUTH_URL   = :openstack_auth_url
  OPENSTACK_USERNAME   = :openstack_username
  OPENSTACK_API_KEY    = :openstack_api_key
  OPENSTACK_TENANT     = :openstack_tenant
  UNIQUE_HELPER_VALUES = :unique_helper_options
  ALPHA                = :alpha
  NUMERIC              = :numeric

  class ConfigFile
    include Singleton

    def self.cloud_credentials
      inst = self.instance
      { :provider => 'OpenStack' }.merge inst[OPENSTACK_OPTIONS]
    end

    def self.web_client_url
      self.instance[WEB_CLIENT_HOST]
    end

    def self.unique_alpha
      self.instance.ensure_unique_helper_key
      unless self.instance[UNIQUE_HELPER_VALUES][ALPHA]
        self.instance[UNIQUE_HELPER_VALUES][ALPHA] =
            (0...50).map{65.+(rand(25)).chr}.join
        self.instance.save
      end
      self.instance[UNIQUE_HELPER_VALUES][ALPHA]
    end

    def self.unique_numeric
      self.instance.ensure_unique_helper_key
      unless self.instance[UNIQUE_HELPER_VALUES][NUMERIC]
        self.instance[UNIQUE_HELPER_VALUES][NUMERIC] =
            (0...50).map{rand(9)}.join
        self.instance.save
      end
      self.instance[UNIQUE_HELPER_VALUES][NUMERIC]
    end

    def initialize
      if File.exists?(PATH)
        @config = YAML.load_file( File.open(PATH, 'r+') )
      else
        raise "ERROR: #{PATH} does not exist. Please execute run/configurator to configure mCloud Features."
      end
    end

    def save
      FileUtils.rm_rf(PATH)
      config_file = File.open(PATH, File::WRONLY|File::CREAT|File::EXCL)
      YAML.dump(@config, config_file)
    end

    def [](key)
      @config[key]
    end

    def ensure_unique_helper_key
      @config[UNIQUE_HELPER_VALUES] ||= {}
    end

  end # class ConfigFile

end # module Configuration

include CloudConfiguration