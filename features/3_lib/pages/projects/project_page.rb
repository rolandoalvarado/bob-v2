require_relative '../secure_page'

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
  option    'imageslist',             xpath: '//div[@class="instance-item clearfix"]/label[text()]'
  option    'image',                  xpath: '//div[@class="instance-item clearfix"]/label[text()="<name>"]'
  option    'security group',         xpath: "//input[@name='securityGroupCheckbox' and @value='<name>']"
  option    'keypair',                xpath: '//select[@id="keypair"]/option[@value="<name>"]'
  row       'instance',               '#instances-template .table-list #instance-item-<id>'
  form      'resize instance',        '#resize-instance-modal'

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

# Type      Name                           Selector
  button    'volume menu',                 '#volume-item-<id> .dropdown-toggle'
  button    'new volume snapshot',         '#volume-item-<id> #create-snapshot'
  form      'new volume snapshot',         '#create-snapshot-modal'
  field     'volume snapshot name',        '#create-snapshot-modal #name'
  field     'volume snapshot description', '#create-snapshot-modal #textarea'
  button    'create volume snapshot',      '#create-snapshot-modal .create-snapshot'
  link      'snapshots tab',               '.nav-tabs .snapshots a'
  table     'volume snapshots',            '#volume-snapshot-list'

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
  row       'floating IP',                   '#floating-ip-list #floating-ip-item-<id>'

  row       'instance',                      '#instances-template .table-list #instance-item-<id>'
  form      'resize instance',               '#resize-instance-modal'

  element   'console output',                '#logsModal'

  # These buttons are accessible via 'Click the <name> button for instance <instance id>'
  button    'instance menu',                 "#instance-item-<id> .dropdown-toggle"
  button    'delete instance',               "#instance-item-<id> .destroy"
  button    'soft reboot instance',          "#instance-item-<id> .soft-reboot"
  button    'hard reboot instance',          "#instance-item-<id> .hard-reboot"
  button    'pause instance',                "#instance-item-<id> .pause"
  button    'resize instance',               "#instance-item-<id> .resize"
  button    'resume instance',               "#instance-item-<id> .resume"
  button    'suspend instance',              "#instance-item-<id> .suspend"
  button    'unpause instance',              "#instance-item-<id> .unpause"
  button    'view console output',           "#instance-item-<id> .logs"
  button    'VNC console',                   "#instance-item-<id> .vnc-console"

  button    'confirm instance deletion',     '#alert-template .okay'
  button    'confirm instance reboot',       "#alert-template .okay"
  button    'confirm instance resize',       "#resize-instance-modal .action-resize-instance"

  element   'image', xpath: "//*[@id='instances-list']//label[text()='<name>']"

  #==========================
  # Collaborators
  #==========================
  link      'collaborators email',           '.chzn-choices'
  link      'collaborators tab',             '.nav-tabs .collaborators a'
  link      'disabled collaborators tab',    '.nav-tabs .collaborators.disabled'
  button    'add collaborator',              '#add-collaborator:not(.disabled)'   
  option    'collaborator',           xpath: '//*[@class="chzn-drop"]//li[text()="<name>"]'
  button    'add collaborator action',       '#add-collaborator-modal .action-add'
  table     'collaborators',                 '#users-template tbody'

end
