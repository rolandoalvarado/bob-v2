require 'fog'

module Fog

  class Collection < Array
    def find_by_name(name)
      find{ |o| o.name == name.to_s }
    rescue Excon::Errors::SocketError
      nil
    end
  end

  module Identity
    class OpenStack

      class Roles < Fog::Collection
        def find_by_name(name)
          Tenant.new(connection.list_roles.body['roles'].find{ |r| r['name'] == name })
        end
      end

      class Users < Fog::Collection
        def all
          load(connection.list_users.body['users'])
        end

        def roles
          connection.list_roles_for_user_on_tenant(self.tenant_id, self.id).body['roles']
        end
      end

    end
  end
end
