require_relative '../secure_page'

class MonitoringPage < SecurePage
  path '/'

  element  "project name",      xpath: '//*[div[@name="<name>"]]'
  element  "tile",              xpath: '//*[div[@name="<name>"]]'
end
