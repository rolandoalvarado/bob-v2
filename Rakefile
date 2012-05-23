require 'rake'
require 'cucumber'
require 'cucumber/rake/task'

task :default do
  system("rake -T")
end

desc "Remove generated files and test output"
task :clean do
  FileUtils.rm_rf "output"
  FileUtils.rm "rerun.txt"
end

task :mkoutputdir do
  FileUtils.mkdir_p("output")  
end

task :inventory => :mkoutputdir
Cucumber::Rake::Task.new(:inventory, "Lists all step definitions and where they are used") do |t|
   t.cucumber_opts =  "--format usage --dry-run --no-profile"
end

task :permissions => :mkoutputdir
Cucumber::Rake::Task.new(:permissions, "Generates a permissions matrix") do |t|
   t.cucumber_opts =  "--tags @permissions --no-profile --require features --dry-run --format Cucumber::Formatter::Relaxdiego::PermissionsMatrix --out output/permissions --require features"
end

task :test => :mkoutputdir
Cucumber::Rake::Task.new(:test) do |t|
   t.profile =  "default"
end

task :upcoming_only => :mkoutputdir
Cucumber::Rake::Task.new(:upcoming_only, "Runs all scenarios that are tagged with @future") do |t|
   t.profile =  "upcoming_only"
end

task :ci => :mkoutputdir
Cucumber::Rake::Task.new(:ci, "Run Cucumber features for a CI environment.") do |t|
   t.profile =  "ci"
end

task :wip => :mkoutputdir
Cucumber::Rake::Task.new(:wip, "Runs all scenarios that are tagged with @wip") do |t|
   t.profile =  "wip"
end

task :unused_steps => :mkoutputdir
Cucumber::Rake::Task.new(:unused_steps, "Show the step definitions that are not being used") do |t|
   t.profile =  "unused_steps"
end

task :profiler => :mkoutputdir
Cucumber::Rake::Task.new(:profiler, "Profiles each step definition and provides duration of each") do |t|
   t.profile =  "steps_duration"
end

task :rerun => :mkoutputdir
Cucumber::Rake::Task.new(:rerun, "Rerun failed steps, if any") do |t|
   t.profile =  "rerun"
end

desc "Configure the Cucumber environment"
task :configure do
  system("bundle update")
  def available_capybara_drivers
    drivers = ['selenium']
    drivers << 'webkit' if Gem::Specification.find_all_by_name('capybara-webkit').count > 0
    drivers << 'poltergeist' if  Gem::Specification.find_all_by_name('capybara/poltergeist').count > 0
    drivers.join(', ')
  end

  require 'rubygems'
  require 'yaml'
  require File.expand_path('features/support/cloud_configuration.rb', File.dirname(__FILE__))
  
  include CloudConfiguration
  @config = {}
  @options = {}
  @options[WEB_CLIENT_HOST] = ENV['WEB_CLIENT_HOST']
  @options[OPENSTACK_AUTH_URL] = "http://mc.cb-1-1.morphcloud.net:35357/v2.0/tokens"
  @options[OPENSTACK_USERNAME] = ENV['WEB_CLIENT_USER']
  @options[OPENSTACK_API_KEY] = ENV['WEB_CLIENT_API_KEY']
  @options[OPENSTACK_TENANT] = ENV['WEB_CLIENT_TENANT']
  @options[CAPYBARA_DRIVER] = ENV['CAPYBARA_DRIVER']

  # Remove old configuration file location
  FileUtils.rm_rf( File.expand_path('../../configuration.rb', __FILE__) )

  config_path = CloudConfiguration::PATH
  puts "Creating new configuration file at #{ config_path }"
  
  def cleanup_url(hash, key)
    url = hash[key]
    url = "http://#{url}" if url.match(/^http/).nil?
    hash[key] = url.gsub(/\/?$/, '')
  end
  
  openstack_options = @config[OPENSTACK_OPTIONS] ||= {}

  @config[WEB_CLIENT_HOST] = @options[WEB_CLIENT_HOST]
  cleanup_url(@config, WEB_CLIENT_HOST)

  openstack_options[OPENSTACK_AUTH_URL] = @options[OPENSTACK_AUTH_URL] || openstack_options[OPENSTACK_AUTH_URL] || "#{ @options[WEB_CLIENT_HOST] }:35357/v2.0/tokens" 
  cleanup_url(openstack_options, OPENSTACK_AUTH_URL)
  openstack_options[OPENSTACK_USERNAME] = @options[OPENSTACK_USERNAME] || openstack_options[OPENSTACK_USERNAME]
  openstack_options[OPENSTACK_API_KEY] = @options[OPENSTACK_API_KEY] || openstack_options[OPENSTACK_API_KEY]
  openstack_options[OPENSTACK_TENANT] = @options[OPENSTACK_TENANT] || openstack_options[OPENSTACK_TENANT]
  @config[CAPYBARA_DRIVER] = @options[CAPYBARA_DRIVER] || @config[CAPYBARA_DRIVER] || 'selenium'

  puts "Writing #{config_path} with contents:"
  puts @config.to_yaml
  FileUtils.rm_rf(config_path)
  config_file = File.open(config_path, File::WRONLY|File::CREAT|File::EXCL)
  YAML.dump(@config, config_file)
end
