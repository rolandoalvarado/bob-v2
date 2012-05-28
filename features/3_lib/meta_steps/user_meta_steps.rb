Then /^Ensure that a user with username (.+) and password (.+) exists$/ do |username, password|
  username           = Unique.username(username)
  @user_attrs        = CloudObjectBuilder.attributes_for(:user, :name => username, :password => password)
  @user_attrs[:name] = Unique.username(@user_attrs[:name])
  @user = IdentityService.instance.ensure_user_exists(@user_attrs)
  EnvironmentCleaner.register(:user, @user.id)
end

Then /^Ensure that a user with username (.+) does not exist$/ do |username|
  user = IdentityService.session.users.reload.find { |u| u.name == username }
  IdentityService.session.delete_user(user) if user
end


Then /^Register the user named (.+) for deletion at exit$/ do |username|
  user = IdentityService.session.users.reload.find { |u| u.name == username }
  EnvironmentCleaner.register(:user, user.id) if user
end


Then /^The user (.+) should not exist in the system$/ do |username|
  username = Unique.username(username)

  sleeping(1).seconds.between_tries.failing_after(20).tries do
    user = IdentityService.session.users.find_by_name(username)
    raise "User #{ username } should not exist, but it does." if user
  end
end
