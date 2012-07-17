require_relative '../secure_page'

class MonitoringPage < SecurePage
  path '/monitoring'

  element  "project name",      xpath: '//*[div[@name="<name>"]]'
  element  "tile",              "#dash_body .green[name='<name>']"

  graph    'cpu_usage',         '#cpu_usage'
  graph    'network_usage',     '#network_usage'
  graph    'block_usage',       '#block_usage'
end
