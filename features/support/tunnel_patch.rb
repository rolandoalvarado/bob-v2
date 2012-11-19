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

require 'net/ssh/gateway'

def create_tunnel(host, username)
  raise 'ERROR: Host must be specified!'     if host.to_s.empty?
  raise 'ERROR: Username must be specified!' if username.to_s.empty?

  begin
    print "Connecting to #{ host } via SSH tunnel... "

    gateway = Net::SSH::Gateway.new(host, username)
    ports = [35357, 8776, 9292, 8774, 8773, 5000]
    ports.each do |port|
      gateway.open(host, port, port)
    end

    puts 'Connected.'

    return gateway
  rescue => e
    abort "ERROR: #{ e.inspect }"
  end
end

def destroy_tunnel(tunnel)
  if tunnel
    tunnel.shutdown!
    puts "SSH tunnel closed."
  end
end
