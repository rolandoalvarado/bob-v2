# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'

module Configuration
  PATH               = File.expand_path('../../support/config.yml', __FILE__)
  WEB_CLIENT_HOST    = :web_client_host
  OPENSTACK_OPTIONS  = :openstack_options
  OPENSTACK_AUTH_URL = :openstack_auth_url
  OPENSTACK_USERNAME = :openstack_username
  OPENSTACK_API_KEY  = :openstack_api_key
  OPENSTACK_TENANT   = :openstack_tenant

  class Configuration
    include Singleton

    def initialize
      if File.exists?(PATH)
        @config = YAML.load_file( File.open(PATH, 'r+') )
      else
        raise "ERROR: #{PATH} does not exist. Please execute run/configurator to configure mCloud Features."
      end
    end

    def [](key)
      @config[key]
    end
  end # class Configuration

end # module Configuration