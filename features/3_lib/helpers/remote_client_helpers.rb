def remote_client_connection(protocol, ip_address, username, options = {})
  case protocol.upcase
  when 'RDP'
    result = `rdesktop #{ ip_address } -u #{ username } -p #{ options[:password] } 2>&1`
    unless $? == 0  # command exited with error/s
      raise "The instance is not publicly accessible on #{ ip_address } via RDP. " +
            "The error returned was: #{ result }"
    end
  when 'SSH'
    private_key_filename = "#{ test_keypair_name }.pem"
    raise "Couldn't find private key file '#{ private_key_filename }'" unless File.exists?(private_key_filename)
    options.merge!( port: 22, timeout: 30, keys: [ File.expand_path(private_key_filename) ] )

    begin
      Net::SSH.start(ip_address, username, options)
    rescue Exception => e
      raise "The instance is not publicly accessible on #{ ip_address } via SSH. " +
            "The error returned was: #{ e.message }"
    end
  end
end

def test_keypair_name
  'bob'
end
