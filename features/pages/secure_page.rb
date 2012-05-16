#
# Superclass for pages that are only accessible after login
#

require_relative 'web_client_page'

class SecurePage < WebClientPage
  # Left menu items shared by all secure pages
  link 'dashboard', '.main-nav *:not(.disabled) a[href="/"]'
  link 'projects',  '.main-nav *:not(.disabled) a[href="/projects"]'
  link 'users',     '.main-nav *:not(.disabled) a[href="/users"]'
  link 'usage',     '.main-nav *:not(.disabled) a[href="/usage"]'
  link 'support',   '.main-nav *:not(.disabled) a[href="http://www.morphlabs.com/support"]'

  # Top links shared by all secure pages
  link 'username',  '.l-head a[href="/current_user"]'
  link 'settings',  '.l-head a[href="/current_user"]'
  link 'logout',    '.l-head a[href="/logout"]'
end
