def logged_in?
  page.has_content?('Logout')
end

def logout
  click_on 'Logout'
end