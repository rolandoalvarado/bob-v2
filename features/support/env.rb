require 'rubygems'
require 'bundler/setup'

config_path = File.expand_path('../../../config.yml', __FILE__)

if File.exists? config_path
  config = YAML.load_file(File.open(config_path, 'r+'))
else
  puts "WARNING: I couldn't find #{config_path}"
  config = {}
end

if config['host'].nil? || config['host'].empty?
  print "Which mCloud environment would you like to verify? "
  config['host'] = STDIN.gets.chomp
end

config['host'] = "http://#{config['host']}" if config['host'].match(/^http/).nil?

# Overrides the method +method_name+ in +obj+ with the passed block
def override_method(obj, method_name, &block)
  # Get the singleton class/eigenclass for 'obj'
  klass = class <<obj; self; end

  # Undefine the old method (using 'send' since 'undef_method' is protected)
  klass.send(:undef_method, method_name)

  # Create the new method
  klass.send(:define_method, method_name, block)
end

def sort_features(features)
  return features.sort { |x,y|  x <=> y }
end

AfterConfiguration do |configuration|
  featurefiles =  configuration.feature_files

  override_method(configuration, :feature_files) {
    sort_features(featurefiles);
  }
end