require_relative '../web_client_page'

class ProjectsPage < WebClientPage
  path '/projects'

  button 'create project',                '#create-project'
  button 'disabled create project',       '#create-project.disabled'
  field  'project name',                  '#new-project-name'
  field  'project description',           '#new-project-description'
  button 'save project',                  '#save-project'
  span   'new project name error',        "span.error[for='new-project-name']"
  span   'new project description error', "span.error[for='new-project-description']"

  # To click on a project link, use ProjectsPage#project_link( name: NAME_OF_PROJECT ).click
  element 'project name',         "td.project-details[title='<name>']"
  link   'project',              xpath: "//*[@id='project-list']//td[@title='<name>']/..//a[@class='view-project']"
  link   'edit project',         xpath: "//*[@id='project-list']//td[@title='<name>']/..//a[@class='modify-project']"
  link   'delete project',         xpath: "//*[@id='project-list']//td[@title='<name>']/..//a[@class='destroy-project']"
  button 'project menu',         xpath: "//*[@id='project-list']//td[@title='<name>']/..//a[@class='dropdown-toggle']"
  button 'delete confirmation',         xpath: "//*[@class='btn btn-danger okay']"
end
