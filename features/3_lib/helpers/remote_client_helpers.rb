def remote_client_connection(protocol, ip_address, username, options = {})
  case protocol.upcase
  when 'RDP'
    result = `rdesktop #{ ip_address } -u #{ username } -p #{ options[:password] } 2>&1`
    unless $? == 0  # command exited with error/s
      raise "The instance is not publicly accessible on #{ ip_address } via RDP. " +
            "The error returned was: #{ result }"
    end
  when 'SSH'
    options.merge!( port: 2222, timeout: 10 )
    begin
      Net::SSH.start(ip_address, username, options) do |ssh|
        # Test connection and automatically close
      end
    rescue Exception => e
      raise "The instance is not publicly accessible on #{ ip_address } via SSH. " +
            "The error returned was: #{ e.message }"
    end
  end
end
