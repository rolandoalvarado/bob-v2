require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

  button    'new instance',    '#create-instance:not(.disabled)'
  form      'new instance',    '#create-instance-modal'
  radiolist 'images',          '#instances-list'
  field     'server name',     '#server-name'
  checklist 'security groups', xpath: "//input[@name='securityGroupCheckbox']/../../.."
  button    'create instance', '#create-instance-modal .create-instance'
end
