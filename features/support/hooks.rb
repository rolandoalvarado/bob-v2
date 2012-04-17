require 'fileutils'

def tmp_screenshots_dir
  File.join(File.expand_path("../../../23452344317467_tmp_screenshots_dir", __FILE__))
end

AfterConfiguration do |config|
  FileUtils.rm_rf(tmp_screenshots_dir) if Dir.exists?(tmp_screenshots_dir)
  Dir.mkdir(tmp_screenshots_dir)
  puts "Your Unique.alpha value is #{ Unique.alpha }"
end

After do |scenario|
  if scenario.failed? && page.driver.respond_to?('browser')
    page.driver.browser.save_screenshot(File.join(tmp_screenshots_dir, "scenario.#{__id__}.png"))
    embed(File.join(tmp_screenshots_dir, "scenario.#{__id__}.png"), "image/png", "Screenshot")
  end
end

at_exit do
  FileUtils.rm_rf(tmp_screenshots_dir)
end