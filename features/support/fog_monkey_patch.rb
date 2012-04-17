require_relative 'gems_under_development'

# Fixes/patches that I have not submitted to the fog repo since I'm still
# observing them. -- Mark (mmaglana@morphlabs.com)
module Fog

  class Collection < Array
    def find_by_name(name)
      reload
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

    end # class OpenStack
  end # module Identity

end
