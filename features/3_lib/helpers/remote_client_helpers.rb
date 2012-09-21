def remote_client_connection(protocol, ip_address, username, options = {})
  case protocol.upcase
  when 'RDP'
    result = `rdesktop #{ ip_address } -u #{ username } -p #{ options[:password] } 2>&1`
    unless $? == 0  # command exited with error/s
      raise "The instance is not publicly accessible on #{ ip_address } via RDP. " +
            "The error returned was: #{ result }"
    end
  when 'SSH'
    private_key = ComputeService.session.private_keys[test_keypair_name]
    raise "Couldn't find private key for keypair '#{ test_keypair_name }'!" unless private_key
    options.merge!( port: 22, timeout: 30, key_data: [ private_key ], user_known_hosts_file: '/dev/null' )
    begin
      Net::SSH.start(ip_address, username, options) do |ssh|
        output = ssh.exec!(' hostame ;ip addr show ; top -n 1 ; ')
        puts "Output : #{output}"
      end
    rescue => e
      raise "The instance is not publicly accessible on #{ ip_address } via SSH. " +
            "The error returned was: #{ e.inspect }"
    end
  end
end

def test_keypair_name
  'bob'
end
