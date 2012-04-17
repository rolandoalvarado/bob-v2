# For gems that I am still heavily developing, it's easier for me to update
# and test them if I symlink to them directly. However, for others who just
# use the gems listed below, they're better off just requiring the gem
# directly. So I automated the process of deciding how to require the rb files.
# You normally don't have to edit this file AND you don't have to require
# the gems anywhere else.
#
# --Mark (mmaglana@morphlabs.com)

gems = [
  { :name => 'activepage',      :symlink => 'activepage'      },
  { :name => 'diego_formatter', :symlink => 'diego_formatter' },
  { :name => 'fog',             :symlink => 'fog'             }
]

gems.each do |gem_info|
  symlink = File.expand_path("../#{ gem_info[:symlink] }", __FILE__)

  if Dir.exists? symlink
    Dir["#{ symlink }/*.rb"].each do |file|
      require_relative file
    end
  else
    require gem_info[:name]
  end
end