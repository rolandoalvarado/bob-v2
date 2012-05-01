require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

  create_instance_button    '#create-instance'
  create_instance_form      '#create-instance-modal'
end
