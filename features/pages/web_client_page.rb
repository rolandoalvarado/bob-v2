# Common elements shared by all pages in the web client

class WebClientPage < Page
  button "logout", xpath: "//a[@href='/logout']"
end
