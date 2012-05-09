# Common elements shared by all pages in the web client

class WebClientPage < Page
  button "logout", "a[href='/logout']"

  form   "login",  "div.login-container"
end
