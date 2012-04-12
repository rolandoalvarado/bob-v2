module CloudObjectBuilder

  def self.attributes_for(object_type, hash = {})
    if self.respond_to? "attributes_for_#{ object_type.to_s }"
      send("attributes_for_#{ object_type.to_s }", hash)
    else
      raise "I don't know how to build the attributes for cloud object type '#{ object_type.to_s }'"
    end
  end

  def self.attributes_for_user(attributes)
    attributes[:email]      ||= attributes.delete('email') || attributes.delete('Email') || Faker::Internet.email
    attributes[:enabled]    ||= attributes.delete('enabled') || true
    attributes[:name]       ||= attributes.delete('name') || attributes.delete('Username') || Faker::Name.name
    attributes[:tenant_id]  ||= attributes.delete('tenant_id')
    attributes[:password]   ||= attributes.delete('password') || attributes.delete('Password')
    attributes
  end

  def self.attributes_for_tenant(attributes)
    attributes[:description] ||= attributes.delete('description') || Faker::Lorem.paragraph
    attributes[:enabled]     ||= attributes.delete('enabled') || true
    attributes[:name]        ||= attributes.delete('name') || Faker::Company.name
    attributes
  end

end