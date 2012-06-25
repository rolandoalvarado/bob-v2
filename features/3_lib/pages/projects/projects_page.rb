require_relative '../secure_page'

class ProjectsPage < WebClientPage
  path '/projects'

  button  'create project',                '#new-project'
  button  'disabled create project',       '#new-project.disabled'
  field   'project name',                  '#new-project-name'
  field   'project description',           '#new-project-description'
  button  'save project',                  '#create-project'
  span    'new project name error',        "span.error[for='new-project-name']"
  span    'new project description error', "span.error[for='new-project-description']"

  # To click on a project link, use ProjectsPage#project_link( name: NAME_OF_PROJECT ).click
  element 'project name',          xpath:  "//td[@class='project-details clickable-row'][@title='<name>']"
  link    'project',               xpath:  "//*[@id='project-list']//td[@title='<name>']/..//a[@class='view-project']"
  link    'edit project',          xpath:  "//td[@title='<name>']/..//a[@class='edit-project']"
  link    'disabled edit project', xpath:  "//td[@title='<name>']/..//a[@class='edit-project disabled'][@disabled='disabled']"
  link    'delete project',        xpath:  "//td[@title='<name>']/..//a[@class='destroy-project']"
  button  'project menu',          xpath:  "//*[@id='project-list']//td[@title='<name>']/..//a[@class='dropdown-toggle']"
  button  'delete confirmation',   xpath:  "//*[@class='btn btn-danger okay']"
  field   'unable to delete',      xpath:  "//h4[@class='alert-heading'][contains(text(),'Unable to delete the project')]"
end
