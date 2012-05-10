require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

  button    'new instance',          '#create-instance:not(.disabled)'
  button    'disabled new instance', '#create-instance.disabled'
  field     'project name',          '#project-name'
  field     'project description',   '#project-description'
  button    'modify project',        '#edit-project'
  form      'new instance',          '#create-instance-modal'
  radiolist 'images',                '#instances-list'
  field     'server name',           '#server-name'
  checklist 'security groups',       xpath: "//input[@name='securityGroupCheckbox']/../../.."
  button    'create instance',       '#create-instance-modal .create-instance'
  table     'instances',             '#instances-template .table-list'

  span      'project name error',        "span.error[for='project-name']"
  span      'project description error', "span.error[for='project-description']"


  #==========================
  # Instance-reated elements
  #==========================
  link      'access security tab',           '.nav-tabs .access-and-security a'
  button    'new floating IP allocation',    '#allocate-btn'
  form      'new floating IP allocation',    '#floating-ip-allocate-modal'
  dropdown  'pool',                          '#pool'
  dropdown  'instance',                      '#instance-id'
  button    'create floating IP allocation', '#floating-ip-allocate-modal .action-allocate'

  # These buttons are accessible via 'Click the <name> button for instance <instance id>'
  button    'instance menu',    "#instance-item-<id> .dropdown-toggle"
  button    'delete instance',  "#instance-item-<id> .destroy"

  button    'confirm instance deletion',     '#alert-template .okay'
end
