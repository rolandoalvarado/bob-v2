def logged_in?
  page.has_content?('Logout')
end