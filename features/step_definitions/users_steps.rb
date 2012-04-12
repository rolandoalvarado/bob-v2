#=================
# GIVENs
#=================

Given /^The following user exists:$/ do |table|
  identity_service = IdentityService.instance
  user_attrs       = CloudObjectsBuilder.attributes_for(:user, table.hashes[0])
  user             = identity_service.users.find_by_name(user_attrs[:name])

  if user
    user.update(user_attrs)
  else
    user_attrs[:tenant_id] = identity_service.test_tenant.id
    user = identity_service.users.new(user_attrs)
    user.save
  end
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
