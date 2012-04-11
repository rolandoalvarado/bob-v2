#=================
# GIVENs
#=================

Given /^The following user exists:$/ do |user_details_table|
  identity_service = IdentityService.instance
  user_hash        = user_details_table.hashes[0]
  user             = identity_service.find_user(user_hash)

  if user
    # Make sure that the user attributes match
    # what's stated in the feature file
    identity_service.update_user(user, user_hash)
  else
    tenant = identity_service.create_tenant
    identity_service.create_user( {'tenant_id' => tenant.id}.merge(user_hash) )
  end
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
