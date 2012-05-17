require_relative '../secure_page'

class ProjectPage < WebClientPage
  path '/projects'

 # Project 
 # Type      Name               Selector
  button    'new instance',                  '#create-instance:not(.disabled)'
  button    'disabled new instance',         '#create-instance.disabled'
  field     'project name',                  '#project-name'
  field     'project description',           '#project-description'
  button    'modify project',                '#edit-project'
  form      'new instance',                  '#create-instance-modal'
  span      'project name error',            "span.error[for='project-name']"
  span      'project description error',     "span.error[for='project-description']"

 # Instance
 # Type      Name                            Selector
  radiolist 'images',                        '#instances-list'
  option    'imageslist',             xpath: '//div[@class="instance-item clearfix"]/label[text()]'
  option    'image',                  xpath: '//div[@class="instance-item clearfix"]/label[text()="<name>"]'
  field     'server name',                   '#server-name'
  checklist 'security groups',        xpath: "//input[@name='securityGroupCheckbox']/../../.."
  option    'security group',         xpath: "//input[@name='securityGroupCheckbox' and @value='<name>']"
  option    'keypair',                xpath: '//select[@id="keypair"]/option[@value="<name>"]'
  button    'create instance',               '#create-instance-modal .create-instance'
  table     'instances',                     '#instances-template .table-list'
  row       'instance',                      '#instances-template .table-list #instance-item-<id>'
  form      'resize instance',               '#resize-instance-modal'
  element   'console output',                '#logsModal'

 # Floating IP
 # Type      Name                            Selector
  link      'access security tab',           '.nav-tabs .access-and-security a'
  button    'new floating IP allocation',    '#allocate-btn'
  form      'new floating IP allocation',    '#floating-ip-allocate-modal'
  dropdown  'pool',                          '#pool'
  dropdown  'instance',                      '#instance-id'
  button    'create floating IP allocation', '#floating-ip-allocate-modal .action-allocate'
  table     'floating IPs',                  '#floating-ip-list'
  row       'floating IP',                   '#floating-ip-list #floating-ip-item-<id>'

 # Volume
 # Type      Name                            Selector
  button    'new volume',                    '#add-volume:not(.disabled)'
  button    'disabled new volume',           '#add-volume.disabled'
  form      'new volume',                    '#add-volume-modal'
  field     'volume name',                   '#name'
  field     'volume description',            '#textarea'
  field     'volume size',                   '#appendedInput'
  button    'create volume',                 '#save-volume'
  table     'volumes',                       '#volume-template tbody'
  span      'new volume form error',         'span.error[for="name"], span.error[for="appendedInput"]'

 # Collaborators
 # Type      Name                            Selector
  link      'email option',                  '#user-id_chzn'
  link      'collaborators tab',             '.nav-tabs .collaborators a'
  link      'disabled collaborators tab',    'li.collaborators.disabled'
  button    'add collaborator',              '#add-collaborator:not(.disabled)'   
  option    'collaborator',           xpath: '//div[@class="chzn-drop"]//li[text()="<name>"]'
  button    'add collaborator action',       '#add-collaborator-modal .action-add'
  table     'collaborators',                 '#users-template tbody'

 # These buttons are accessible via 'Click the <name> button for instance <instance id>'
 # Type      Name                            Selector
  button    'instance menu',                 "#instance-item-<id> .dropdown-toggle"
  button    'delete instance',               "#instance-item-<id> .destroy"
  button    'soft reboot instance',          "#instance-item-<id> .soft-reboot"
  button    'hard reboot instance',          "#instance-item-<id> .hard-reboot"
  button    'pause instance',                "#instance-item-<id> .pause"
  button    'unpause instance',              "#instance-item-<id> .unpause"
  button    'resume instance',               "#instance-item-<id> .resume"
  button    'suspend instance',              "#instance-item-<id> .suspend"
  button    'resize instance',               "#instance-item-<id> .resize"
  button    'snapshot instance',             "#instance-item-<id> .snapshot"
  button    'console instance',              "#instance-item-<id> .vnc-console"
  button    'logs instance',                 "#instance-item-<id> .logs"
  button    'view console output',           "#instance-item-<id> .logs"
  button    'confirm instance resize',       "#resize-instance-modal .action-resize-instance"
  button    'confirm instance deletion',     '#alert-template .okay'
  button    'confirm instance reboot',       "#alert-template .okay"

  element   'image',                  xpath: "//*[@id='instances-list']//label[text()='<name>']"
end
