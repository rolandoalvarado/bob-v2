require_relative 'gems'

# Fixes/patches that I have not submitted to the fog repo since I'm still
# observing them. -- Mark (mmaglana@morphlabs.com)

module Fog

  class Collection < Array
    def find_by_name(name)
      reload rescue nil
      find{ |o| o.name == name.to_s }
    rescue Excon::Errors::SocketError
      nil
    end # find_by_name
  end # class Collection < Array

  module Identity
    class OpenStack < Fog::Service

      class Users < Fog::Collection
        def all
          load(connection.list_users.body['users'])
        end
      end # class Users

      class Tenant < Fog::Model
        def grant_user_role(user_id, role_id)
          connection.add_user_to_tenant(self.id, user_id, role_id)
        rescue Excon::Errors::Conflict => error
          raise error unless error.response.status == 409
        end

        def revoke_user_role(user_id, role_id)
          connection.remove_user_from_tenant(self.id, user_id, role_id)
        rescue Excon::Errors::NotFound => error
          raise error unless error.response.status == 409
        end
      end # class Tenant

    end # class OpenStack
  end # module Identity

end
