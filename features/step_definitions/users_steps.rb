#=================
# GIVENs
#=================

Given /^The following user exists:$/ do |table|
  user_attrs        = CloudObjectBuilder.attributes_for(:user, table.hashes[0])
  user_attrs[:name] = Unique.username(user_attrs[:name])

  IdentityService.instance.ensure_user_exists(user_attrs)
end

Given /^a user is logged in$/ do
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

#=================
# WHENs
#=================


#=================
# THENs
#=================
