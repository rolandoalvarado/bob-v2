#=================
# GIVENs
#=================

Given /^The following user exists:$/ do |table|
  identity_service = IdentityService.instance
  user_attrs       = CloudObjectBuilder.attributes_for(:user, table.hashes[0])
  user             = identity_service.users.find_by_name(user_attrs[:name])

  if user
    user.update(user_attrs)
  else
    identity_service.create_user(user_attrs)
  end
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
