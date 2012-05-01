require_relative '../web_client_page'

class ProjectsPage < WebClientPage
  path '/projects'

  create_project_button     '#create-project'
  project_name_field        '#new-project-name'
  project_description_field '#new-project-description'
  save_project_button       '#save-project'
end
