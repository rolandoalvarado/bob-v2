#=================
# GIVENs
#=================

Given /^The following user exists:$/ do |table|
  user_attrs        = CloudObjectBuilder.attributes_for(:user, table.hashes[0])
  user_attrs[:name] = Unique.username(user_attrs[:name])
  identity_service  = IdentityService.instance
  user              = identity_service.users.find_by_name(user_attrs[:name])

  if user
    user.update(user_attrs)
  else
    identity_service.create_user(user_attrs)
  end
end

Given /^a user is logged in$/ do
  steps %{
    * The following user exists:
      | Username | Password |
      | rstark   | 123qwe   |
  }
  @page = LoginPage.new
  @page.visit
  @page.should_be_valid
  @page.fill_in :username, Unique.username('rstark')
  @page.fill_in :password, '123qwe'
  @page.submit
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
