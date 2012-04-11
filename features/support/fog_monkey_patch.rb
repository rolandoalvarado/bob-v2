# Monkey patch Fog::Identity::OpenStack::Users while find_by_name is not defined
module Fog
  module Identity
    class OpenStack
      class Users < Fog::Collection
        def find_by_name(name)
          user = self.find { |user| user.name == name }
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