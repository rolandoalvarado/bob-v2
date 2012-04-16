# I need this for easier development of activepage. Most of the time,
# it's easier to just symlink to my local repo of the activepage gem.
# Although for other users, they're better off just requiring the gem itself

activepage_dir = File.expand_path('../activepage', __FILE__)

if Dir.exists? activepage_dir
  Dir["#{ activepage_dir }/*.rb"].each do |file|
    require_relative file
  end
else
  require 'activepage'
end