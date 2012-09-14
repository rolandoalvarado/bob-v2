# This is a patch for the authentication code on the mcloud-fog gem.
# This should/might prevent most "Connection refused - connect(2) (Excon::Errors::SocketError)" errors.
# Just a quick and dirty patch for connecting via SSH tunnel. Don't judge me. - Bob

if ConfigFile.tunnel
  module Fog
    module OpenStack

      # legacy v1.0 style auth
      def self.authenticate_v1(options, connection_options = {})
        uri = options[:openstack_auth_uri]
        connection = Fog::Connection.new(uri.to_s, false, connection_options)
        @openstack_api_key  = options[:openstack_api_key]
        @openstack_username = options[:openstack_username]
        response = connection.request({
          :expects  => [200, 204],
          :headers  => {
            'X-Auth-Key'  => @openstack_api_key,
            'X-Auth-User' => @openstack_username
          },
          :host     => uri.host,
          :method   => 'GET',
          :path     =>  (uri.path and not uri.path.empty?) ? uri.path : 'v1.0'
        })

        mgmt_url = response.headers['X-Server-Management-Url']
        uri = URI.parse(mgmt_url)
        host = uri.host
        mgmt_url.gsub! host, 'localhost'

        return {
          :token => response.headers['X-Auth-Token'],
          :server_management_url => mgmt_url
        }
      end

      # Keystone Style Auth
      def self.authenticate_v2(options, connection_options = {})
        uri = options[:openstack_auth_uri]
        connection = Fog::Connection.new(uri.to_s, false, connection_options)
        @openstack_api_key  = options[:openstack_api_key]
        @openstack_username = options[:openstack_username]
        @openstack_tenant   = options[:openstack_tenant]
        @openstack_auth_token = options[:openstack_auth_token]
        @service_name         = options[:openstack_service_name]
        @identity_service_name = options[:openstack_identity_service_name]
        @endpoint_type         = options[:openstack_endpoint_type] || 'publicURL'

        if @openstack_auth_token
          req_body = {
            'auth' => {
              'token' => {
                'id' => @openstack_auth_token
              }
            }
          }
        else
          req_body = {
            'auth' => {
              'passwordCredentials'  => {
                'username' => @openstack_username,
                'password' => @openstack_api_key.to_s
              }
            }
          }
        end
        req_body['auth']['tenantName'] = @openstack_tenant if @openstack_tenant

        body = retrieve_tokens_v2(connection, req_body, uri)

        svc = body['access']['serviceCatalog'].
          detect{|x| @service_name.include?(x['type']) }

        unless svc
          unless @openstack_tenant
            response = Fog::Connection.new(
              "#{uri.scheme}://#{uri.host}:5000/v2.0/tenants", false).request({
              :expects => [200, 204],
              :headers => {'Content-Type' => 'application/json',
                           'X-Auth-Token' => body['access']['token']['id']},
              :host    => uri.host,
              :method  => 'GET'
            })

            body = MultiJson.decode(response.body)
            if body['tenants'].empty?
              raise Errors::NotFound.new('No Tenant Found')
            else
              req_body['auth']['tenantName'] = body['tenants'].first['name']
            end
          end

          body = retrieve_tokens_v2(connection, req_body, uri)
          svc = body['access']['serviceCatalog'].
            detect{|x| @service_name.include?(x['type']) }
        end

        identity_svc = body['access']['serviceCatalog'].
          detect{|x| @identity_service_name.include?(x['type']) } if @identity_service_name
        tenant = body['access']['token']['tenant']
        user = body['access']['user']

        mgmt_url = svc['endpoints'].detect{|x| x[@endpoint_type]}[@endpoint_type]
        identity_url = identity_svc['endpoints'].detect{|x| x['publicURL']}['publicURL'] if identity_svc
        token = body['access']['token']['id']
        expires = body['access']['token']['expires']

        uri = URI.parse(mgmt_url)
        host = uri.host
        mgmt_url.gsub! host, 'localhost'
        identity_url.gsub!(host, 'localhost') if identity_svc

        {
          :user                     => user,
          :tenant                   => tenant,
          :token                    => token,
          :expires                  => expires,
          :server_management_url    => mgmt_url,
          :identity_public_endpoint => identity_url,
          :current_user_id          => body['access']['user']['id']
        }
      end

    end
  end
end
