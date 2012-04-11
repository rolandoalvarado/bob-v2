module UserMethods
  def find_user(hash)
    attributes = extract_user_attributes(hash)
    if attributes[:name]
      @service.users.find_by_name(attributes[:name])
    else
      raise "Don't know what key to use for finding user #{hash}"
    end
  end

  def create_user(attributes = {})
    attributes = extract_user_attributes(attributes)

    user = @service.users.new(attributes)
    raise "User #{user} couldn't be created!" unless user.save
    user
  end

  def extract_user_attributes(attributes)
    attributes[:email]      ||= attributes.delete('email') || attributes.delete('Email') || Faker::Internet.email
    attributes[:enabled]    ||= attributes.delete('enabled') || true
    attributes[:name]       ||= attributes.delete('name') || attributes.delete('Username') || Faker::Name.name
    attributes[:tenant_id]  ||= attributes.delete('tenant_id')
    attributes[:password]   ||= attributes.delete('password') || attributes.delete('Password')
    attributes
  end

  def update_user(user, attributes)
    attributes = extract_user_attributes(attributes)
    raise "Couldn't update user attributes!" unless user.update(attributes)
  end
end