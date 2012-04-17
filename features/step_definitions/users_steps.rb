#=================
# GIVENs
#=================

Given /^I have the following credentials:$/ do |table|
  user_attrs        = CloudObjectBuilder.attributes_for(:user, table.hashes[0])
  user_attrs[:name] = Unique.username(user_attrs[:name])

  IdentityService.instance.ensure_user_exists(user_attrs)
end

Given /^I am logged in$/ do
  user_attrs = CloudObjectBuilder.attributes_for(:user, {
                 :name     => Unique.username('rstark'),
                 :password => '123qwe'
               })
  IdentityService.instance.ensure_user_exists(user_attrs)

  @page = LoginPage.new
  @page.visit
  @page.should_be_valid
  @page.fill_in :username, user_attrs[:name]
  @page.fill_in :password, user_attrs[:password]
  @page.submit
end

Given /^[Aa] user with a role of (.+) exists in the project$/ do |friendly_name|
  identity_service = IdentityService.instance
  @user_attrs      = CloudObjectBuilder.attributes_for(:user, :name => Unique.username('rstark'))
  user             = identity_service.ensure_user_exists(@user_attrs)

  role_name = RoleNameDictionary.db_name(friendly_name)
  role      = identity_service.roles.find_by_name(role_name)
  @project.add_user(user.id, role.id)

  pending # express the regexp above with the code you wish you had
end


#=================
# WHENs
#=================


#=================
# THENs
#=================
