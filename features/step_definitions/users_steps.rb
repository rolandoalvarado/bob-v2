#=================
# GIVENs
#=================

Given /^A user with username '(.+)' and a password '(.+)' exists$/ do |username, password|
  steps %{
    * Ensure that a user with username #{ username } and password #{ password } exists
  }
end

Given /^[Aa] user with a role of (.+) exists in the project$/ do |role_name|
  # identity_service = IdentityService.instance
  # @user_attrs      = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('rstark'))
  # user             = identity_service.ensure_user_exists(@user_attrs)
  #
  # role_name = RoleNameDictionary.db_name(friendly_name)
  # role      = identity_service.roles.find_by_name(role_name)
  # @project.add_user(user.id, role.id)

  username = 'rstark'

  steps %{
    * Ensure that a user with username #{ username } exists
    * Ensure that the user has a role of #{ role_name }
    * Raise an error if the user does not have a role of #{ role_name }
  }

  pending # express the regexp above with the code you wish you had
end


#=================
# WHENs
#=================


#=================
# THENs
#=================
