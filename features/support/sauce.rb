require 'sauce'
require 'sauce/cucumber'
require_relative 'unique'

## To use you must set the `capybara_driver` to sauce in `config.yml`
#

Sauce.config do |cfg|
  cmd_args = ARGV.map {|a| a.match(/@.*$/) ? a.gsub('~', 'not ') : nil}.compact
  cfg[:job_name] = "Dashboard (#{Capybara.app_host})"
  cfg[:tags] = [Unique.alpha, Time.now.to_s, Capybara.app_host].push(*cmd_args)

  default_config_path = File.expand_path('../sauce.yml.default', __FILE__)
  custom_config_path  = File.expand_path('../sauce.yml', __FILE__)

  config_path = File.exists?(custom_config_path) ? custom_config_path : default_config_path
  cfg.opts.merge!(YAML.load(File.read(config_path)))
end
