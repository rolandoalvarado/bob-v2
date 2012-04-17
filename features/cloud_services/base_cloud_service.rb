# BASE CLASS to be inherited by other classes in this directory

# This class implements the singleton pattern. More info at
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
require 'singleton'

class BaseCloudService
  include Singleton
  include CloudConfiguration
  include Fog                 # Make Fog classes directly available to child classes

  def initialize
    raise "#{ self.class } should define an initialize method"
  end

  #==================================
  # PRIVATE METHODS
  #==================================

  private

  def service
    @service
  end

  def service=(value)
    @service = value
  end
end