require_relative '../secure_page'

class ProjectPage < SecurePage
  path '/projects'

  button    'close',                              '.close'

  tab       'instances and volumes',              '.nav-tabs .instances-and-volumes a'

  button    'new instance',                       '#new-instance:not(.disabled)'
  button    'disabled new instance',              '#new-instance.disabled'
  field     'project name',                       '#project-name'
  field     'project description',                '#project-description'
  button    'modify project',                     '#update-project'
  form      'new instance',                       '#new-instance-modal'
  message   'new instance error',                 '#new-instance-modal .error'
  radiolist 'images',                             '#instances-list'
  field     'server name',                        '#server-name'
  field     'server password',                        '#password'
  checklist 'security groups',                    xpath: "//input[@name='securityGroupCheckbox']/../../.."
  button    'create instance',                    '#create-instance'
  table     'instances',                          '#instances-template .table-list'
  option    'imageslist',                         xpath: '//div[@class="instance-item clearfix"]/label[text()]'
  option    'image',                              xpath: '//div[@class="instance-item clearfix"]/label[text()="<name>"]'
  checkbox  'security group',                     xpath: "//input[@name='securityGroupCheckbox' and @value='<name>']"
  option    'keypair',                            xpath: '//select[@id="keypair"]/option[@value="<name>"]'
  dropdown  'keypair',                            '#keypair'
  field     'password',                           '#password'
  row       'instance',                           '#instances-template .table-list #instance-item-<id>'
  form      'resize instance',                    '#resize-instance-modal'
  element 'project name',                         "td.project-details[title='<name>']"
  #==========================
  # Edit Quota Elements
  #==========================
# Type      Name                                  Selector
  button    'quota modify',                       xpath: '//*[@id="edit-quota"]' 
  link      'disabled quota modify',              xpath: '//*[@id="edit-quota"]' 
  form      'modify quota',                       '#quota-form'
  message   'Modify Quota',                       xpath: '//h3[text()="Modify Quota"]'
  message   'update quota',                       '#alert-template .alert-success' #xpath: '//*[div[@class="alert alert-success"]]'
  
  button    'disabled quota modify',              '.show-quota-form.disabled'
  button    'save quota edit',                    '#update-quota'
  field     'floating ips quota edit',            xpath: '//input[@name="floating_ips"]'
  field     'volumes quota edit',                 xpath: '//input[@name="volumes"]'
  field     'cores quota edit',                   xpath: '//input[@name="cores"]'
  element   'quota edit error',                   '.alert-heading'
  element   'quota edit error2',                  xpath: '//div[@class="control-group error"]'

# Type      Name                                  Selector
  span      'project name error',                 "span.error[for='project-name']"
  span      'project description error',          "span.error[for='project-description']"

  #==========================
  # Security Group Elements
  #==========================
  button    'new security group',                 "#new-security-group"
  button    'edit security group',                "#security-item-<id> .edit-security-rules"
  button    'delete security group',              "#security-item-<id> .delete-security-group"  
  button    'Context Menu',                       xpath: "//tr[@id='security-item-<id>']/..//a[@class='dropdown-toggle']"
  form      'new security',                       "#new-security-group-modal"
  form      'security group rules',               "#security-group-rules-modal"
  link      'delete security group',              "#security-item-<id> .delete-security-group"
  link      'edit security group',                "#security-item-<id> .edit-security-rules"
  link      'security group',                     "#security-item-<id> .edit-security-rules"
  element   'security groups',                    "#security-groups-list"
  tab       'access security',                    ".nav-tabs .access-and-security a"
  

  #Elements in the New Security form
  field     'security group name',                "#new-security-name"
  field     'security group description',         "#new-security-description"
  button    'create security',                    "#create-security-group"
  message   'new security group form error',      "span.error[for='new-security-name'], span.error[for='new-security-description']"
  span      'new security group form error',      "span.error[for='new-security-name'], span.error[for='new-security-description']"
  element   'security group form error message',  "#security-group-rules-form .error"

  dropdown  'ip protocol',                        "#ip-protocol"
  field     'from port', xpath:                   '//form[@id="security-group-rules-form"]//input[@id="from-port"]'
  field     'to port', xpath:                     '//form[@id="security-group-rules-form"]//input[@id="to-port"]'
  field     'CIDR',    xpath:                     '//form[@id="security-group-rules-form"]//input[@id="cidr"]'
  button    'add security group rule',            '#save-security-group-rule'
  button    'close security group rule',          xpath: '//*[@id="security-group-rules-modal"]/div[3]/a' 
  field     'list ip protocol',                   '#security-group-rules-list div.ip-protocoll'  
  field     'list from port',                     '#security-group-rules-list div.from-port'   
  field     'list to port',                       '#security-group-rules-list div.to-port'   
  field     'list cidr',                          '#security-group-rules-list div.cidr'   

  # The following buttons appear with the confirmation dialog that appears
  # when you click the delete security group.
  button  'confirm security group deletion',      "a.okay"
  button  'cancel security group deletion',       "a.cancel"
  
  #==========================
  # Volume-related elements
  #==========================

# Type      Name                                  Selector
  button    'new volume',                         '#new-volume:not(.disabled)'
  button    'disabled new volume',                '#new-volume.disabled'
  form      'new volume',                         '#new-volume-modal'
  field     'volume name',                        '#name'
  field     'volume description',                 '#textarea'
  field     'volume size',                        '#appendedInput'
  button    'create volume',                      '#save-volume'
  table     'volumes',                            '#volume-list tbody'

  button    'delete volume',                      '#volume-item-<id> a[data-action="delete-volume"]'
  button    'volume delete confirmation',         'a.okay'

# Type      Name                                  Selector
  button    'volume menu',                        '#volume-item-<id> .dropdown-toggle'
  button    'volume context menu',                '#volume-item-<id> .dropdown-toggle'
  #button    'volume delete',                     '#volume-item-<id> a[data-action="delete-volume"]'
  button    'new volume snapshot',                '#volume-item-<id> a[data-action="create-snapshot"]'
  form      'new volume snapshot',                '#new-volume-snapshot-modal'
  field     'volume snapshot name',               '#new-volume-snapshot-modal #name'
  field     'volume snapshot description',        '#new-volume-snapshot-modal #textarea'
  button    'create volume snapshot',             '#create-volume-snapshot'
  tab       'snapshots',                          '.nav-tabs .snapshots a'

# Type      Name                                  Selector
  button    'volume snapshot menu',               xpath: "//*[@id='volume-snapshot-list']//td[contains(@class, 'name') and normalize-space(text())=\"<name>\"]/..//*[@class='dropdown-toggle']"
  button    'delete volume snapshot',             xpath: "//*[@id='volume-snapshot-list']//td[contains(@class, 'name') and normalize-space(text())=\"<name>\"]/..//*[@class='delete-snapshot']"
  button    'confirm volume snapshot deletion',   '#alert-template .okay'
  table     'volume snapshots',                   '#volume-snapshot-list'

# Type      Name                                  Selector
  span      'new volume form error',              'span.error[for="name"], span.error[for="appendedInput"]'

# Type      Name                                  Selector
  button    'attach volume',                      '#volume-item-<id> .attach'
  form      'attach volume',                      '#attach-volume-modal'
  dropdown  'attachable instance',                '#attach-volume-modal #instance'
  button    'confirm volume attachment',          '#attach-volume'
  button    'volume attach confirmation',         '#attach-volume'
  button    'detach volume',                      '#volume-item-<id> .detach'
  button    'volume detach confirmation',         '#alert-template .okay'
  row       'volume',                             '#volume-item-<id>'

  #==========================
  # Monitoring-related elements
  #==========================
  element  "project details",                      xpath: '//*[div[@name="<name>"]]'

  #==========================
  # Instance-related elements
  #==========================
  button    'new floating IP allocation',         '#allocate-floating-ip:not(.disabled)'
  form      'new floating IP allocation',         '#allocate-floating-ip-modal'
  dropdown  'pool',                               '#pool'
  dropdown  'instance',                           '#instance-id'
  button    'create floating IP allocation',      '#allocate'
  table     'floating IPs',                       '#floating-ip-list'
  row       'floating IP',                        '#floating-ip-list #floating-ip-item-<id>'
  #row       'associated floating IP', xpath:      "//*[@id='floating-ip-list']//*[@class='floating-ip' and text()=\"<name>\"]/.."
  row       'associated floating IP',              xpath: "//*[@id='floating-ip-list']//td[contains(@class, 'instance') and normalize-space(text())=\"<name>\"]/.."
  row       'instance',                           '#instances-template .table-list #instance-item-<id>'
  form      'resize instance',                    '#resize-instance-modal'

  element   'console output',                     '#logsModal'


  # These buttons are accessible via 'Click the <name> button for instance <instance id>'
  button    'instance menu',                      "#instance-item-<id> .dropdown-toggle"
  button    'delete instance',                    "#instance-item-<id> .destroy"
  button    'soft reboot instance',               "#instance-item-<id> .soft-reboot"
  button    'hard reboot instance',               "#instance-item-<id> .hard-reboot"
  button    'pause instance',                     "#instance-item-<id> .pause"
  button    'resize instance',                    "#instance-item-<id> .resize"
  button    'resume instance',                    "#instance-item-<id> .resume"
  button    'suspend instance',                   "#instance-item-<id> .suspend"
  button    'unpause instance',                   "#instance-item-<id> .unpause"
  button    'view console output',                "#instance-item-<id> .logs"
  button    'VNC console',                        "#instance-item-<id> .vnc-console"

  button    'confirm instance deletion',          '#alert-template .okay'
  button    'confirm instance reboot',            "#alert-template .okay"
  button    'resize instance confirmation',       "#resize-instance"

  button    'confirm resize instance',            "#instance-item-<id> .confirm-resize"

  element   'image',                              xpath: "//*[@id='instances-list']//label[text()='<name>']"


  #==========================
  # Collaborators
  #==========================
  link      'collaborators email',                '.chzn-choices'
  tab       'collaborators',                      '.nav-tabs .collaborators a'
  tab       'disabled collaborators',             '.nav-tabs .collaborators.disabled'
  button    'add collaborator',                   '#add-collaborator:not(.disabled)'
  option    'collaborator',                       xpath: '//*[@class="chzn-drop"]//*[li[text()="<name>"]]'
  button    'add collaborator',                   'a.btn-primary'
  table     'collaborators',                      xpath: "//*[tr[@class='user']]/td[normalize-space(text())='<name>']"

  dropdown  'Users',                              "#user-id"
  field     'email',                              xpath: '//form[@id="add-collaborator-form"]//input[@class="default"]'
  option    'email',                              xpath: '//select[@id="user-id"]/option[@value="<name>"]'
  link      'user',                               xpath: '//*[@class="chzn-drop"]//*[li[text()="<name>"]]'
  row       'User',                               xpath: "//*[@id='users-list']//td[normalize-space(text())=\"<name>\"]/.."
  element   'collaborator',                       "#users-list"
  
end
