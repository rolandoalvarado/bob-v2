module TenantMethods
  def create_tenant(attributes = {})
    attributes[:description] ||= attributes.delete('description') || Faker::Lorem.paragraph
    attributes[:enabled]     ||= attributes.delete('enabled') || true
    attributes[:name]        ||= attributes.delete('name') || Faker::Company.name
    tenant = @service.tenants.new(attributes)
    raise "Tenant #{tenant} couldn't be created!" unless tenant.save
    tenant
  end
end