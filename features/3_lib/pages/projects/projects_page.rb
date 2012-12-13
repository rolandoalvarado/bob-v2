require_relative '../secure_page'

class ProjectsPage < SecurePage
  path '/projects'

  form    'new project',                   '#new-project-modal'
  button  'create project',                '#new-project:not(.disabled)'
  button  'disabled create project',       '#new-project.disabled'
  field   'project name',                  '#new-project-name'
  field   'project description',           '#new-project-description'
  button  'save project',                  '#create-project'

  message 'new project error',             "#new-project-modal span.error"
  message 'new project name error',        "span.error[for='new-project-name']"
  message 'new project description error', "span.error[for='new-project-description']"

  # To click on a project hyperlink, use ProjectsPage#project_link( name: NAME_OF_PROJECT ).click
  row       'project',                        xpath:  "//td[@title='<name>']"
  hyperlink 'project',                        xpath:  "//td[@title='<name>']/..//a[@class='view-project']"
  hyperlink 'edit project',                   xpath:  "//td[@title='<name>']/..//a[@class='edit-project']"
  hyperlink 'disabled edit project',          xpath:  "//td[@title='<name>']/..//a[@class='edit-project disabled'][@disabled='disabled']"
  hyperlink 'delete project',                 xpath:  "//td[@title='<name>']/..//a[@class='destroy-project']"
  hyperlink 'disabled delete project',        xpath:  "//td[@title='<name>']/..//a[@class='destroy-project disabled'][@disabled='disabled']"
  button    'context menu',                   xpath:  "//td[@title='<name>']/..//a[@class='dropdown-toggle']"
  button    'project menu',                   xpath:  "//td[@title='<name>']/..//a[@class='dropdown-toggle']"
  button    'menu',                           xpath:  "//td[@title='<name>']/..//a[@class='dropdown-toggle']"
  button    'delete confirmation',            xpath:  "//*[@class='btn btn-danger okay']"
  field     'unable to delete',               xpath:  "//h4[@class='alert-heading'][contains(text(),'Unable to delete the project')]"
end
