require 'fileutils'

def tmp_screenshots_dir
  File.join(File.expand_path("../../../23452344317467_tmp_screenshots_dir", __FILE__))
end

AfterConfiguration do |config|
  failed_count = IdentityService.session.tenants.count { |t| t.name.start_with?('failed delete') }
  if failed_count > ConfigFile.failed_tenant_limit
    puts "\033[31mThis test cannot continue because there are too many failed projects (#{ failed_count }). " +
         "Consider running `run/cleaner --failed` to clear these.\033[0m"
    Cucumber.wants_to_quit = true
  else
    FileUtils.rm_rf(tmp_screenshots_dir) if Dir.exists?(tmp_screenshots_dir)
    Dir.mkdir(tmp_screenshots_dir)
    puts "Verifying requirements against #{ ConfigFile.web_client_url }"
    puts "Your Unique.alpha value is #{ Unique.alpha }"
  end
end

Before do |scenario|
  # Reset credentials for all services
  [ComputeService, IdentityService, ImageService, VolumeService].each do |service|
    service.session.reset_credentials
  end
end

After do |scenario|
  page = Capybara.current_session

  case Capybara.current_driver
  when :selenium
    page.driver.browser.save_screenshot(File.join(tmp_screenshots_dir, "scenario.#{__id__}.png"))
  when :webkit
    page.driver.render(File.join(tmp_screenshots_dir, "scenario.#{__id__}.png"))
  end

  embed(File.join(tmp_screenshots_dir, "scenario.#{__id__}.png"), "image/png", "Screenshot")
end

Around do |scenario, block|
  start_time = Time.now
  block.call
  end_time = Time.now
  print " #{start_time} #{ "%.2f" % (end_time - start_time) }x"
end

at_exit do
  FileUtils.rm_rf(tmp_screenshots_dir) if Dir.exists?(tmp_screenshots_dir)
  EnvironmentCleaner.delete_test_objects
  puts # blank line
  EnvironmentCleaner.delete_orphans
end
