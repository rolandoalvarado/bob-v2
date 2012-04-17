#=================
# GIVENs
#=================

Given /^[Aa] project exists in the system$/ do
  proj_attrs       = CloudObjectBuilder.attributes_for(:project, :name => Unique.name('Project 1'))
  identity_service = IdentityService.instance
  @project         = identity_service.ensure_project_exists(proj_attrs)

  raise "Project couldn't be initialized!" if @project.nil? || @project.id.empty?
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
