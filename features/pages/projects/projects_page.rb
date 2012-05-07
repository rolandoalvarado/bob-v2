require_relative '../web_client_page'

class ProjectsPage < WebClientPage
  path '/projects'

  button 'create project',      '#create-project'
  button 'disabled create project',      '#create-project.disabled'
  field  'project name',        '#new-project-name'
  field  'project description', '#new-project-description'
  button 'save project',        '#save-project'

  # To click on a project link, use ProjectsPage#project_link( name: NAME_OF_PROJECT ).click
  link   'project',              xpath: "//*[@id='project-list']//td[text()='<name>']/..//a[@class='view-project']"
end
