require_relative 'web_client_page'

class RootPage < WebClientPage
  path '/'

  link 'user page',  '.main-nav *:not(.disabled) a[href="/users"]'
end
