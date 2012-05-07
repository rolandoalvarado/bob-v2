require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

# Type      Name               Selector
  button    'new instance',    '#create-instance:not(.disabled)'
  button    'no new instance',   '#create-instance.disabled'
  form      'new instance',    '#create-instance-modal'
  radiolist 'images',          '#instances-list'
  field     'server name',     '#server-name'
  checklist 'security groups', xpath: "//input[@name='securityGroupCheckbox']/../../.."
  button    'create instance', '#create-instance-modal .create-instance'
  table     'instances',       '#instances-template .table-list'
end
