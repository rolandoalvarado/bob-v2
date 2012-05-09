source :rubygems

gem 'activesupport'
gem 'anticipate'
gem 'cucumber'
gem 'faker'
gem 'fog', :git => 'git://github.com/MorphGlobal/fog.git', :branch => 'development'
gem 'diego_formatter', :git => 'git://github.com/relaxdiego/diego_formatter.git', :branch => 'master'
gem 'rspec'
gem 'syntax'
gem 'capybara'
gem 'rb-fsevent', :require => false
gem 'guard-cucumber', :require => false

# A NOTE ABOUT GROUPS
# From http://yehudakatz.com/2010/05/09/the-how-and-why-of-bundler-groups/
#
# bundle install is opt-out, while Bundler.require is opt-in. This is because
# the common usage of groups is to specify gems for different environments
# (such as development, test and production) and you shouldn’t need to specify
# that you want the “development” and “test” gems just to get up and running.
# On the other hand, you don’t want your test dependencies loaded in
# development or production.

group :webkit_driver do
  if /QMake version 2\.\d+/.match(`qmake -v`)
    puts 'NOTICE: Qt 2.0+ framework found.'
    gem 'capybara-webkit'
  else
    puts "NOTICE: Qt framework not found."
  end
end

group :phantomjs_driver do
  if /1\.5\.\d+/.match(`phantomjs -v`)
    puts "NOTICE: PhantomJS 1.5+ found."
    gem 'poltergeist'
  else
    puts "NOTICE: PhantomJS 1.5+ not found."
  end
end