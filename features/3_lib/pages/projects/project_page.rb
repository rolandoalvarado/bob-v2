require_relative '../secure_page'

class ProjectPage < WebClientPage
  path '/projects'

  tab       'instances and volumes', '.nav-tabs .instances-and-volumes a'

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
  # Security Group Elements
  #==========================
  button    'new security',            "#new-security-group"
  button    'modify security group',   "#security-item-<id> .edit-security-rules"
  button    'delete security group',   "#security-item-<id> .delete-security-group"  
  button    'Context Menu',            xpath: "//tr[@id='security-item-<id>']/..//a[@class='dropdown-toggle']"
  form      'new security',            "#new-security-group-form"
  form      'security group rules',    "#security-group-rules-form"
  link      'delete security group',   '#security-item-<id> .delete-security-group'
  element   'security groups',         "#security-groups-list"
  tab       'access security',         '.nav-tabs .access-and-security a'

  #Elements in the New Security form
  field     'security group name',           "#new-security-name"
  field     'security group description',    "#new-security-description"
  button    'create security',               "#create-security-group"
  span      'new security form error',       "span.error[for='new-security-name'], span.error[for='new-security-description']"

  option    'ip protocol', xpath:            '//select[@id="ip-protocol"]/option[text()="<name>"]'
  field     'from port', xpath:              '//form[@id="security-group-rules-form"]//input[@id="from-port"]'
  field     'to port', xpath:                '//form[@id="security-group-rules-form"]//input[@id="to-port"]'
  field     'CIDR',    xpath:                '//form[@id="security-group-rules-form"]//input[@id="cidr"]'
  button    'add security group rule',       '#save-security-group-rule'
  button    'close security group rule', xpath: '//*[@id="security-group-rules-modal"]/div[3]/a' 
  field     'list ip protocol',              '#security-group-rules-list div.ip-protocoll'  
  field     'list from port',                '#security-group-rules-list div.from-port'   
  field     'list to port',                  '#security-group-rules-list div.to-port'   
  field     'list cidr',                     '#security-group-rules-list div.cidr'   

  # The following buttons appear with the confirmation dialog that appears
  # when you click the delete security group.
  button  'confirm security  group deletion', "a.okay"
  button  'cancel security group deletion',  "a.cancel"
  
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

  button    'delete volume',               '#volume-item-<id> a[data-action="delete-volume"]'
  button    'volume delete confirmation',  'a.okay'

# Type      Name                           Selector
  button    'volume menu',                 '#volume-item-<id> .dropdown-toggle'
  button    'volume context menu',         '#volume-item-<id> .dropdown-toggle'
  button    'new volume snapshot',         '#volume-item-<id> #create-snapshot'
  form      'new volume snapshot',         '#create-snapshot-modal'
  field     'volume snapshot name',        '#create-snapshot-modal #name'
  field     'volume snapshot description', '#create-snapshot-modal #textarea'
  button    'create volume snapshot',      '#create-snapshot-modal .create-snapshot'
  tab       'snapshots',                   '.nav-tabs .snapshots a'

# Type      Name                                Selector
  button    'volume snapshot menu',      xpath: "//*[@id='volume-snapshot-list']//td[contains(@class, 'name') and normalize-space(text())=\"<name>\"]/..//*[@class='dropdown-toggle']"
  button    'delete volume snapshot',    xpath: "//*[@id='volume-snapshot-list']//td[contains(@class, 'name') and normalize-space(text())=\"<name>\"]/..//*[@class='delete-snapshot']"
  button    'confirm volume snapshot deletion', '#alert-template .okay'
  table     'volume snapshots',                 '#volume-snapshot-list'

# Type      Name                    Selector
  span      'new volume form error', 'span.error[for="name"], span.error[for="appendedInput"]'

# Type      Name                         Selector
  button    'attach volume',             '#volume-item-<id> #attach'
  form      'attach volume',             '#attach-volume-modal'
  dropdown  'attachable instance',       '#attach-volume-modal #instance'
  button    'confirm volume attachment', '#attach-volume-modal .attach-volume'
  row       'volume',                    '#volume-item-<id>'

  #==========================
  # Instance-related elements
  #==========================
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
  tab       'collaborators',                 '.nav-tabs .collaborators a'
  tab       'disabled collaborators',        '.nav-tabs .collaborators.disabled'
  button    'add collaborator',              '#add-collaborator:not(.disabled)'
  option    'collaborator',           xpath: '//*[@class="chzn-drop"]//li[text()="<name>"]'
  button    'add collaborator action',       '#add-collaborator-modal .action-add'
  table     'collaborators',                 '#users-template tbody'

end
