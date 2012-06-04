require 'fileutils'

def tmp_screenshots_dir
  File.join(File.expand_path("../../../23452344317467_tmp_screenshots_dir", __FILE__))
end

def export_keypair

  compute_service = Fog::Compute.new(ConfigFile.cloud_credentials)
  keypair_name    = ConfigFile.keypair_name
  web_client_url  = ConfigFile.web_client_url

  if keypair = compute_service.key_pairs.get(keypair_name)
    puts "Keypair #{ keypair_name } exists in #{ web_client_url }"
    puts "  #{ keypair.to_json }"
  else
    puts "Setting up keypair #{ keypair_name } on #{ web_client_url }..."

    public_key = File.read(ConfigFile.keypair_path)
    compute_service.create_key_pair(keypair_name, public_key)
    sleep(0.5)

    if keypair = compute_service.key_pairs.get(keypair_name)
      puts "Keypair #{ keypair_name } successfully imported into #{ web_client_url }"
      puts "  #{ keypair.to_json }"
    else
      puts "Failed to import keypair #{ keypair_name } into #{ web_client_url }"
    end
  end

end

AfterConfiguration do |config|
  FileUtils.rm_rf(tmp_screenshots_dir) if Dir.exists?(tmp_screenshots_dir)
  Dir.mkdir(tmp_screenshots_dir)
  puts "Verifying requirements against #{ ConfigFile.web_client_url }"
  puts "Your Unique.alpha value is #{ Unique.alpha }"

  export_keypair
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
  print " #{ "%.2f" % (end_time - start_time) }x"
end

at_exit do
  FileUtils.rm_rf(tmp_screenshots_dir)
  EnvironmentCleaner.delete_test_objects
end
