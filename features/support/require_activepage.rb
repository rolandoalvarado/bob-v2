# I need this for easier development of activepage. Especially since the
# activepage gem is still under heavy development, thus most of the time,
# it's easier for me to just symlink to my local of the gem. For other users,
# they're better off just requiring the gem itself

activepage_dir = File.expand_path('../activepage', __FILE__)

if Dir.exists? activepage_dir
  Dir["#{ activepage_dir }/*.rb"].each do |file|
    require_relative file
  end
else
  require 'activepage'
end