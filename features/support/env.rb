require 'rubygems'
require 'bundler/setup'
require 'faker'

# Ensure that features are sorted by their filenames alphabetically
#==================================================================
def override_method(obj, method_name, &block)
  klass = class <<obj; self; end
  klass.send(:undef_method, method_name)
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
#==================================================================

puts "env.rb loaded"