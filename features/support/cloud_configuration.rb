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
  CAPYBARA_DRIVER      = :capybara_driver
  UNIQUE_HELPER_VALUES = :unique_helper_options
  ALPHA                = :alpha
  NUMERIC              = :numeric
  REPEAT               = :repeat
  WAIT                 = :wait
  SHORT                = :short
  LONG                 = :long
  NODE_QUERY_WAIT      = :node
  NODE_QUERY_RETRIES   = :node
  TEN                  = :ten
  FIFTEEN              = :fifteen
  TWENTY               = :twenty
  FORTY                = :forty

  class ConfigFile
    include Singleton

    def self.cloud_credentials
      inst = self.instance
      { :provider => 'OpenStack' }.merge inst[OPENSTACK_OPTIONS]
    end

    def self.admin_username
      cloud_credentials[OPENSTACK_USERNAME]
    end

    def self.web_client_url
      self.instance[WEB_CLIENT_HOST]
    end


    def self.repeat_node
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][NODE_QUERY_RETRIES]
        self.instance[REPEAT][NODE_QUERY_RETRIES] = 3
        self.instance.save
      end
      self.instance[REPEAT][NODE_QUERY_RETRIES]
    end

    def self.wait_node
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][NODE_QUERY_WAIT]
        self.instance[WAIT][NODE_QUERY_WAIT] = 10
        self.instance.save
      end
      self.instance[WAIT][NODE_QUERY_WAIT]
    end

    def self.wait_short
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][SHORT]
        self.instance[WAIT][SHORT] = 1
        self.instance.save
      end
      self.instance[WAIT][SHORT]
    end

    def self.wait_long
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][LONG]
        self.instance[WAIT][LONG] = 10
        self.instance.save
      end
      self.instance[WAIT][LONG]
    end

    def self.repeat_short
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][SHORT]
        self.instance[REPEAT][SHORT] = 30
        self.instance.save
      end
      self.instance[REPEAT][SHORT]
    end
    
    def self.repeat_ten
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][TEN]
        self.instance[REPEAT][TEN] = 10
        self.instance.save
      end
      self.instance[REPEAT][TEN]
    end
    
    def self.repeat_fifteen
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][FIFTEEN]
        self.instance[REPEAT][FIFTEEN] = 15
        self.instance.save
      end
      self.instance[REPEAT][FIFTEEN]
    end
    
    def self.repeat_twenty
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][TWENTY]
        self.instance[REPEAT][TWENTY] = 20
        self.instance.save
      end
      self.instance[REPEAT][TWENTY]
    end
    
    def self.repeat_forty
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][FORTY]
        self.instance[REPEAT][FORTY] = 40
        self.instance.save
      end
      self.instance[REPEAT][FORTY]
    end
    

    def self.repeat_long
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][LONG]
        self.instance[REPEAT][LONG] = 60
        self.instance.save
      end
      self.instance[REPEAT][LONG]
    end

    def self.capybara_driver
      self.instance[CAPYBARA_DRIVER].to_sym
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

    def ensure_repeat_and_wait_key
      @config[REPEAT] ||= {}
      @config[WAIT] ||= {}
    end

  end # class ConfigFile

end # module Configuration

include CloudConfiguration
