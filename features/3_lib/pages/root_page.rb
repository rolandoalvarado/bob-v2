#
# To be used only by Then /^Click the logout button if currently logged in$/
# to remove any modal overlays in the page so that Bob can click buttons.
#

require_relative 'web_client_page'

class RootPage < WebClientPage
  path '/'
end
