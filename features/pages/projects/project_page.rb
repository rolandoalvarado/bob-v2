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

# Type      Name                         Selector
  span      'project name error',        "span.error[for='project-name']"
  span      'project description error', "span.error[for='project-description']"

  #==========================
  # Volume-related elements
  #==========================

# Type      Name                    Selector
  button    'new volume',          '#add-volume:not(.disabled)'
  button    'disabled new volume', '#add-volume.disabled'
  form      'new volume',          '#add-volume-modal'
  field     'volume name',         '#name'
  field     'volume description',  '#textarea'
  field     'volume size',         '#appendedInput'
  button    'create volume',       '#save-volume'
  table     'volumes',             '#volume-template tbody'

# Type      Name                    Selector
  span      'new volume form error', 'span.error[for="name"], span.error[for="appendedInput"]'

  #==========================
  # Instance-related elements
  #==========================
  link      'access security tab',           '.nav-tabs .access-and-security a'
  button    'new floating IP allocation',    '#allocate-btn'
  form      'new floating IP allocation',    '#floating-ip-allocate-modal'
  dropdown  'pool',                          '#pool'
  dropdown  'instance',                      '#instance-id'
  button    'create floating IP allocation', '#floating-ip-allocate-modal .action-allocate'
  table     'floating IPs',                  '#floating-ip-list'

  row       'instance',                      '#instances-template .table-list #instance-item-<id>'

  # These buttons are accessible via 'Click the <name> button for instance <instance id>'
  button    'instance menu',                 "#instance-item-<id> .dropdown-toggle"
  button    'delete instance',               "#instance-item-<id> .destroy"
  button    'soft reboot instance',          "#instance-item-<id> .soft-reboot"
  button    'hard reboot instance',          "#instance-item-<id> .hard-reboot"

  button    'confirm instance deletion',     '#alert-template .okay'
  button    'confirm instance reboot',       "#alert-template .okay"

  element   'image', xpath: "//*[@id='instances-list']//label[text()='<name>']"
end
