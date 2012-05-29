# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'
require 'rubygems'
require 'yaml'
require 'fileutils'

module ServerConfiguration
  PATH     = File.expand_path('../../support/server_config.yml', __FILE__)
  USERNAME = 'username'
  PASSWORD = 'password'

  class ServerConfigFile
    include Singleton

    def self.operating_systems
      self.instance.keys
    end

    def self.username(name)
      if operating_systems.include?(name)
        self.instance[name][USERNAME]
      else
        raise "ERROR: Server configuration for #{name} was not found."
      end
    end

    def self.password(name)
      if operating_systems.include?(name)
        password = self.instance[name][PASSWORD]
        password.kind_of?(Array) ? password.sample : password
      else
        raise "ERROR: Server configuration for #{name} was not found."
      end
    end

    def initialize
      if File.exists?(PATH)
        @server = YAML.load_file( File.open(PATH, 'r+') )
      else
        raise "ERROR: #{PATH} does not exist."
      end
    end

    def save
      FileUtils.rm_rf(PATH)
      config_file = File.open(PATH, File::WRONLY|File::CREAT|File::EXCL)
      YAML.dump(@server, config_file)
    end

    def keys
      @server.keys
    end

    def [](key)
      @server[key]
    end

  end # class ConfigFile

end # module Configuration

include ServerConfiguration
