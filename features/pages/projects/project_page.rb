require_relative '../web_client_page'

class ProjectPage < WebClientPage
  path '/projects'

  create_instance_button '#create-instance:not(.disabled)'
  create_instance_form   '#create-instance-modal'

  images_list            "#instances-list input[type='radio']"
  server_name_field      '#server-name'
end
