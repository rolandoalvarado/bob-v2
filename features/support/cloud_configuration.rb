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
  WAIT_IN_SECONDS      = :seconds
  TIMING               = :timing
  MINUTE               = :seconds
  INSTANCE             = :instance
  RESTART              = :restart
  INSTANCE_IN_STATUS   = :instance_in_status
  INSTANCE_DELETE      = :instance_delete
  VOLUME_READY         = :volume_ready
  VOLUME_ATTACH        = :volume_attach
  VOLUME_DETACH        = :volume_detach
  VOLUME_DELETE        = :volume_delete
  RESUME_INSTANCE      = :resume
  TUNNEL               = :tunnel
  SERVER_USERNAME      = :server_username
  CHROME               = :chrome
  INSTANCE_SNAPSHOT    = :instance_snapshot
  TEST_IMAGE           = :test_image
  CLEANUP_OPTIONS      = :cleanup_options
  CLEANUP_EXEMPTIONS   = :exemptions
  FAILED_TENANT_LIMIT  = :failed_tenant_limit

  class ConfigFile
    include Singleton

    def self.cloud_credentials
      inst = self.instance
      { :provider => 'OpenStack' }.merge inst[OPENSTACK_OPTIONS]
    end

    def self.admin_tenant
      cloud_credentials[OPENSTACK_TENANT]
    end

    def self.admin_username
      cloud_credentials[OPENSTACK_USERNAME]
    end

    def self.admin_api_key
      cloud_credentials[OPENSTACK_API_KEY]
    end

    def self.web_client_url
      self.instance[WEB_CLIENT_HOST]
    end

    def self.cleanup_exemptions
      self.instance[CLEANUP_OPTIONS][CLEANUP_EXEMPTIONS]
    end

    def self.minute
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][MINUTE]
        self.instance[REPEAT][MINUTE] = 60
        self.instance.save
      end
      self.instance[REPEAT][MINUTE]
    end
    
    def self.wait_while_instance_is_performing_task
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][MINUTE]
        self.instance[REPEAT][MINUTE] = 60
        self.instance.save
      end
      self.instance[REPEAT][MINUTE]
    end

    def self.timing
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][TIMING]
        self.instance[REPEAT][TIMING] = 10
        self.instance.save
      end
      self.instance[REPEAT][TIMING]
    end

    def self.repeat_node
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][NODE_QUERY_RETRIES]
        self.instance[REPEAT][NODE_QUERY_RETRIES] = 10
        self.instance.save
      end
      self.instance[REPEAT][NODE_QUERY_RETRIES]
    end

    def self.wait_instance_launch
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][INSTANCE]
        self.instance[WAIT][INSTANCE] = 120
        self.instance.save
      end
      self.instance[WAIT][INSTANCE]
    end

    def self.wait_instance_snapshot
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][INSTANCE_SNAPSHOT]
        self.instance[WAIT][INSTANCE_SNAPSHOT] = 30
        self.instance.save
      end
      self.instance[WAIT][INSTANCE_SNAPSHOT]
    end

    def self.wait_instance_resume
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][RESUME_INSTANCE]
        self.instance[WAIT][RESUME_INSTANCE] = 60
        self.instance.save
      end
      self.instance[WAIT][RESUME_INSTANCE]
    end

    def self.wait_restart
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][RESTART]
        self.instance[WAIT][RESTART] = 90
        self.instance.save
      end
      self.instance[WAIT][RESTART]
    end

    def self.wait_instance_delete
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][INSTANCE_DELETE]
        self.instance[WAIT][INSTANCE_DELETE] = 10
        self.instance.save
      end
      self.instance[WAIT][INSTANCE_DELETE]
    end

    def self.wait_volume_attach
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][VOLUME_ATTACH]
        self.instance[WAIT][VOLUME_ATTACH] = 40
        self.instance.save
      end
      self.instance[WAIT][VOLUME_ATTACH]
    end

    def self.wait_volume_detach
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][VOLUME_DETACH]
        self.instance[WAIT][VOLUME_DETACH] = 40
        self.instance.save
      end
      self.instance[WAIT][VOLUME_DETACH]
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
        self.instance[WAIT][SHORT] = 2
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

    def self.wait_seconds
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][WAIT_IN_SECONDS]
        self.instance[WAIT][WAIT_IN_SECONDS] = 5
        self.instance.save
      end
      self.instance[WAIT][WAIT_IN_SECONDS]
    end

    def self.wait_volume_ready
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][VOLUME_READY]
        self.instance[WAIT][VOLUME_READY] = 30
        self.instance.save
      end
      self.instance[WAIT][VOLUME_READY]
    end

    def self.wait_volume_delete
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][VOLUME_DELETE]
        self.instance[WAIT][VOLUME_DELETE] = 20
        self.instance.save
      end
      self.instance[WAIT][VOLUME_DELETE]
    end

    def self.wait_instance_in_status
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[WAIT][INSTANCE_IN_STATUS]
        self.instance[WAIT][INSTANCE_IN_STATUS] = 30
        self.instance.save
      end
      self.instance[WAIT][INSTANCE_IN_STATUS]
    end

    def self.repeat_instance_in_status
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][INSTANCE_IN_STATUS]
        self.instance[REPEAT][INSTANCE_IN_STATUS] = 6
        self.instance.save
      end
      self.instance[REPEAT][INSTANCE_IN_STATUS]
    end

    def self.repeat_volume_ready
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][VOLUME_READY]
        self.instance[REPEAT][VOLUME_READY] = 2
        self.instance.save
      end
      self.instance[REPEAT][VOLUME_READY]
    end

    def self.repeat_instance_launch
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][INSTANCE]
        self.instance[REPEAT][INSTANCE] = 3
        self.instance.save
      end
      self.instance[REPEAT][INSTANCE]
    end

    def self.repeat_instance_delete
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][INSTANCE_DELETE]
        self.instance[REPEAT][INSTANCE_DELETE] = 6
        self.instance.save
      end
      self.instance[REPEAT][INSTANCE_DELETE]
    end

    def self.repeat_volume_detach
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][VOLUME_DETACH]
        self.instance[REPEAT][VOLUME_DETACH] = 3
        self.instance.save
      end
      self.instance[REPEAT][VOLUME_DETACH]
    end

    def self.repeat_short
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][SHORT]
        self.instance[REPEAT][SHORT] = 30
        self.instance.save
      end
      self.instance[REPEAT][SHORT]
    end

    def self.repeat_until_project_is_visible
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][FIFTEEN]
        self.instance[REPEAT][FIFTEEN] = 15
        self.instance.save
      end
      self.instance[REPEAT][FIFTEEN]
    end

    def self.repeat_until_expected_page_is_visible
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][FIFTEEN]
        self.instance[REPEAT][FIFTEEN] = 15
        self.instance.save
      end
      self.instance[REPEAT][FIFTEEN]
    end

    def self.repeat_timing
      self.instance.ensure_repeat_and_wait_key
      unless self.instance[REPEAT][TIMING]
        self.instance[REPEAT][TIMING] = 3
        self.instance.save
      end
      self.instance[REPEAT][TIMING]
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

    def self.repeat_until_task_is_done
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

    def self.tunnel
      self.instance[TUNNEL] == true
    end

    def self.server_username
      self.instance[SERVER_USERNAME]
    end

    def self.chrome
      self.instance[CHROME] == true
    end

    def self.test_image
      self.instance[TEST_IMAGE]
    end

    def self.failed_tenant_limit
      self.instance[FAILED_TENANT_LIMIT]
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

    def []=(key, value)
      @config[key] = value
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
