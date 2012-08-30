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
    options.merge!( port: 22, timeout: 30, key_data: [ private_key ] )
    
    begin
      sleeping(1).seconds.between_tries.failing_after(300).tries do
        Net::SSH.start(ip_address, username, options) do |ssh|
          output = ssh.exec!('ls')
          puts "Output : #{output}"
        end
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
