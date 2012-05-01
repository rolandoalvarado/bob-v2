#==================================================================
# For gems that I am still heavily developing, it's easier for me to update
# and test them if I symlink to them directly. However, for others who just
# use the gems listed below, they're better off just requiring the gem
# directly. So I automated the process of deciding how to require the rb files.
# You normally don't have to edit this file AND you don't have to require
# the gems anywhere else.
#
# --Mark (mmaglana@morphlabs.com)

gems = %w{ diego_formatter fog }

symlink_basedir = '../../localgems'

gems.each do |gem_name|
  break if Object.const_defined?('RelaxdiegoGemClassesLoaded')
  symlink = File.expand_path("../#{ symlink_basedir }/#{ gem_name }", __FILE__)

  if Dir.exists?(symlink)
    Dir["#{ symlink }/*.rb"].each { |file| require_relative file }
  else
    require gem_name
  end
end
#==================================================================

class RelaxdiegoGemClassesLoaded; end