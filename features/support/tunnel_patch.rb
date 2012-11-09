# This is a patch for the authentication code on the mcloud-fog gem.
# This should/might prevent most "Connection refused - connect(2) (Excon::Errors::SocketError)" errors.
# Just a quick and dirty patch for connecting via SSH tunnel. Don't judge me. - Bob

if ConfigFile.tunnel
  class << Fog::OpenStack
    alias_method :authenticate_v1_without_tunnel, :authenticate_v1
    alias_method :authenticate_v2_without_tunnel, :authenticate_v2

    def authenticate_v1(options, connection_options = {})
      credentials = authenticate_v1_without_tunnel(options, connection_options)

      management_url = credentials[:server_management_url]
      uri = URI.parse(management_url)
      host = uri.host
      management_url.gsub! host, 'localhost'

      credentials.merge(:server_management_url => management_url)
    end

    def authenticate_v2(options, connection_options = {})
      credentials = authenticate_v2_without_tunnel(options, connection_options)

      management_url = credentials[:server_management_url]
      identity_url   = credentials[:identity_public_endpoint]

      uri = URI.parse(management_url)
      host = uri.host
      management_url.gsub! host, 'localhost'
      identity_url.gsub!(host, 'localhost') unless (identity_url.nil? || identity_url.empty?)

      credentials.merge(:identity_public_endpoint => identity_url,
                        :server_management_url    => management_url)
    end
  end
end
