#
# Superclass for pages that are only accessible after login
#

require_relative 'web_client_page'

class SecurePage < WebClientPage
  # Left menu items shared by all secure pages
  hyperlink 'monitoring', '.main-nav *:not(.disabled) a[href="/monitoring"]'
  hyperlink 'projects',  '.main-nav *:not(.disabled) a[href="/projects"]'
  hyperlink 'images',    '.main-nav *:not(.disabled) a[href="/images"]'
  hyperlink 'users',     '.main-nav *:not(.disabled) a[href="/users"]'
  hyperlink 'usage',     '.main-nav *:not(.disabled) a[href="/usage"]'
  hyperlink 'support',   '.main-nav *:not(.disabled) a[href="http://www.morphlabs.com/support"]'

  # Top hyperlinks shared by all secure pages
  hyperlink 'username',  '.l-head a[href="/current_user"]'
  hyperlink 'settings',  '.l-head a[href="/current_user"]'
  hyperlink 'logout',    '.l-head a[href="/logout"]'
end
