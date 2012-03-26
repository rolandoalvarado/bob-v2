def get_config_file
  return @config if @config
  config_path = File.expand_path('../../../config.yml', __FILE__)

  if File.exists? config_path
    @config = YAML.load_file(File.open(config_path, 'r+'))
  end
  @config
end
