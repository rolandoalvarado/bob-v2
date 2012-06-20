source :rubygems

gem 'activesupport'
gem 'anticipate'
gem 'cucumber'
gem 'faker'
gem 'morph-fog', :git => 'git://github.com/MorphGlobal/fog.git', :branch => 'development'
gem 'diego_formatter', :git => 'git://github.com/relaxdiego/diego_formatter.git', :branch => 'master'
gem 'rspec'
gem 'slowhandcuke'
gem 'syntax'

gem 'headless'
gem 'capybara'
gem 'poltergeist'

gem 'rb-fsevent', :require => false
gem 'guard-cucumber', :require => false
gem 'pry'


begin
  result = `qmake --version`
rescue
  result = ''
end

if result =~ /QMake version/
  gem 'capybara-webkit'
end

