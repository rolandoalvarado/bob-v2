require_relative '../web_client_page'

class ProjectsPage < WebClientPage
  path '/projects'

  create_project_button     '#create-project'
  project_name_field        '#new-project-name'
  project_description_field '#new-project-description'
  save_project_button       '#save-project'

  # To click on a project link, use ProjectsPage#project_link( name: NAME_OF_PROJECT ).click
  project_link              xpath: "//*[@id='project-list']//td[text()=':name']/..//a[@class='view-project']"
end
