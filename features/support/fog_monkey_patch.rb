# Monkey patch Fog::Identity::OpenStack::Users while find_by_name is not defined
module Fog
  module Identity
    class OpenStack
      class Users < Fog::Collection
        def find_by_name(name)
          user = self.find { |user| user.name == name.to_s }
          unless user
            body = connection.get_user_by_name(name).body
            user = Fog::Identity::OpenStack::User.new(body) if body['user']
          end
          user
        end
      end
    end
  end
end


# Monkey patch Fog::Identity::OpenStack::Tenants while find_by_name is not defined
module Fog
  module Identity
    class OpenStack
      class Tenants < Fog::Collection
        def find_by_name(name)
          tenant = self.find { |tenant| tenant.name == name.to_s }
          unless tenant
            body = connection.get_tenants_by_name(name).body
            tenant_hash = body['tenants'].find { |tenant| tenant['name'] == name }
            tenant = Fog::Identity::OpenStack::User.new(tenant_hash) if tenant_hash
          end
          tenant
        end
      end
    end
  end
end