require 'rubygems'
require 'bundler/setup'
require 'faker'
require 'headless'
require 'cucumber/formatter/html'
require 'anticipate'
require 'pry'
# NOTE: Look at gems.rb for other gems being required

# Ensure capybara webkit is working in headless mode
#headless = Headless.new
#headless.start

include Anticipate

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
