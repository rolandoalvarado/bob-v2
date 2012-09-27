def remote_client_connection(protocol, external_ip, internal_ip, username, options = {})
  case protocol.upcase
  when 'RDP'
    result = `rdesktop #{ external_ip } -u #{ username } -p #{ options[:password] } 2>&1`
    unless $? == 0  # command exited with error/s
      raise "The instance is not publicly accessible on #{ ip_address } via RDP. " +
            "The error returned was: #{ result }"
    end
  when 'SSH'
    private_key = ComputeService.session.private_keys[test_keypair_name]
    raise "Couldn't find private key for keypair '#{ test_keypair_name }'!" unless private_key
    options.merge!( port: 22, timeout: 60, key_data: [ private_key ], user_known_hosts_file: '/dev/null', verbose: 0)
    begin
      Net::SSH.start(external_ip, username, options) do |ssh|
        output = ssh.exec!(' hostname ;ip addr show ; top -n 1 ; ')
        puts "Output : #{output}"
      end
    rescue
      begin
        Net::SSH.start(internal_ip, username, options) do |ssh|
          output = ssh.exec!(' hostname ;ip addr show ; top -n 1 ; ')
          puts "Output : #{output}"
        end
      rescue => e
        raise "The instance is not publicly accessible on both #{ external_ip } and #{ internal_ip } via SSH. " +
              "The error returned was: #{ e.inspect }"
      end
    end
  end
end

def remote_client_check_volume(ip_address, username, delta_time, options={})
  device_file_list = Array.new
  Net::SSH.start(ip_address, username, options) do |ssh|
    # Get a list of all device /dev/vd* files modified/created from x minutes ago
    device_file_list = ssh.exec!("find /dev/vd* -mmin -#{ delta_time }").split
  end

  if device_file_list.empty?
    raise "No new device file has been created on the instance."
  end
end

def test_keypair_name
  'bob'
end
