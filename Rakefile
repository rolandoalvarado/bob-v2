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

desc "Configure the Cucumber environment"
task :configure do
  system("bundle update")
  system("run/configurator --host #{ENV['WEB_CLIENT_HOST']} --username #{ENV['WEB_CLIENT_USER']} --password #{ENV['WEB_CLIENT_API_KEY']} --tenant #{ENV['WEB_CLIENT_TENANT']}  --driver #{ENV['CAPYBARA_DRIVER']}")    
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
Cucumber::Rake::Task.new(:upcoming_only, "Runs all scenarios that are not tagged with @future") do |t|
   t.profile =  "upcoming_only"
end

task :ci => :mkoutputdir
Cucumber::Rake::Task.new(:ci, "Run Cucumber features for a CI environment.") do |t|
   t.profile =  "ci"
end

task :wip => :mkoutputdir
Cucumber::Rake::Task.new(:wip, "Runs all scenarios that are not tagged with @wip") do |t|
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


