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
    attributes[:name]       ||= attributes.delete('name') || attributes.delete('Username') || Unique.username(Faker::Name.name.gsub(' ', '_')[0, 5].downcase)
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

  def self.attributes_for_volume(attributes)
    attributes[:name]        ||= attributes.delete('name') || Faker::Company.name
    attributes[:description] ||= attributes.delete('description') || Faker::Lorem.paragraph
    attributes[:size]        ||= attributes.delete('size') || 1
    BetterHash.new.merge(attributes)
  end

  def self.attributes_for_security_group(attributes)
    attributes[:description] ||= attributes.delete('description') || Faker::Lorem.paragraph
    attributes[:name]        ||= attributes.delete('name') || Faker::Company.name
    BetterHash.new.merge(attributes)
  end

  def self.attributes_for_snapshot(attributes)
    attributes[:name]        ||= attributes.delete('name') || Faker::Company.name
    attributes[:description] ||= attributes.delete('description') || Faker::Lorem.paragraph
    BetterHash.new.merge(attributes)
  end

end

class BetterHash < Hash
  def method_missing(name, *args, &block)
    if has_key?(name)
      self[name]
    else
        super name, *args, &block
    end
  end
end
