require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

# Type      Name               Selector
  button    'new instance',          '#create-instance:not(.disabled)'
  button    'disabled new instance', '#create-instance.disabled'
  field  'project name',                  '#project-name'
  field  'project description',           '#project-description'
  button 'modify project',                  '#edit-project'
  form      'new instance',    '#create-instance-modal'
  radiolist 'images',          '#instances-list'
  field     'server name',     '#server-name'
  checklist 'security groups', xpath: "//input[@name='securityGroupCheckbox']/../../.."
  button    'create instance', '#create-instance-modal .create-instance'
  table     'instances',       '#instances-template .table-list'
  span      'project name error',        "span.error[for='project-name']"
  span      'project description error', "span.error[for='project-description']"

end
