# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'

# The reason why we put wrap the credentials in this class is so that,
# we only need to look at one place to determine what type of cloud we
# are dealing with. While it's highly unlikely that we will change from
# OpenStack to something else in the future, when the event happens, we
# will be able to easily shift by just changing this one file.

class Cloud
  include Singleton
  include Configuration

  attr_reader :credentials

  def initialize
    @credentials = { :provider => 'OpenStack' }.merge(Configuration.instance[OPENSTACK_OPTIONS])
  end
end