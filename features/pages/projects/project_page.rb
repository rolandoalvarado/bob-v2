require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

# Type      Name               Selector
  button    'new instance',          '#create-instance:not(.disabled)'
  button    'disabled new instance', '#create-instance.disabled'

  form      'new instance',    '#create-instance-modal'
  radiolist 'images',          '#instances-list'
  field     'server name',     '#server-name'
  checklist 'security groups', xpath: "//input[@name='securityGroupCheckbox']/../../.."
  button    'create instance', '#create-instance-modal .create-instance'
  table     'instances',       '#instances-template .table-list'

  link      'access security tab',           '.nav-tabs .access-and-security a'
  button    'new floating IP allocation',    '#allocate-btn'
  form      'new floating IP allocation',    '#floating-ip-allocate-modal'
  dropdown  'pool',                          '#pool'
  dropdown  'instance',                      '#instance-id' 
  button    'create floating IP allocation', '#floating-ip-allocate-modal .action-allocate'
end
