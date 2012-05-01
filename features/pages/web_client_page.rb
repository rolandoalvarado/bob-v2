# Common elements shared by all pages in the web client

class WebClientPage < Page
  logout_button xpath: "//a[@href='/logout']"
end
