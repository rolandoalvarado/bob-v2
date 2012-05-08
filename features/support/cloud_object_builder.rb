# This is similar to FactoryGirl, but exclusively designed for mCloud Features
module CloudObjectBuilder

  def self.attributes_for(object_type, hash = {})
    method_name = "attributes_for_#{ object_type.to_s }"
    if self.respond_to? method_name
      send(method_name, hash)
    else
      raise "I don't know how to build the attributes for cloud object type " +
            "'#{ object_type.to_s }'. You may have mispelled it, or you may " +
            "need to define a class method named '#{ method_name }' inside " +
            "#{ File.expand_path('.', __FILE__)}"
    end
  end

  def self.attributes_for_user(attributes)
    attributes[:email]      ||= attributes.delete('email') || attributes.delete('Email') || Faker::Internet.email
    attributes[:enabled]    ||= attributes.delete('enabled') || true
    attributes[:name]       ||= attributes.delete('name') || attributes.delete('Username') || Faker::Name.name
    attributes[:tenant_id]  ||= attributes.delete('tenant_id')
    attributes[:password]   ||= attributes.delete('password') || attributes.delete('Password') || "123qwe"
    BetterHash.new.merge(attributes)
  end

  def self.attributes_for_tenant(attributes)
    attributes[:description] ||= attributes.delete('description') || Faker::Lorem.paragraph
    attributes[:enabled]     ||= attributes.delete('enabled') || true
    attributes[:name]        ||= attributes.delete('name') || Faker::Company.name
    BetterHash.new.merge(attributes)
  end

  def self.attributes_for_project(attributes)
    attributes_for_tenant(attributes)
  end

end

class BetterHash < Hash
  def method_missing(name, *args, &block)
    if has_key?(name)
      self[name]
    else
        super
    end
  end
end
