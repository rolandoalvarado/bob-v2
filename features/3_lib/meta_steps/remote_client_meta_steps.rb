Then /^Connect to (.+) instance with floating IP (.+) via (.+)$/ do |image_name, floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  username = ServerConfigFile.username(image_name)
  password = ServerConfigFile.password(image_name)

  begin
    case remote_client.upcase
    when 'RDP'
      %x{ rdesktop #{ ip_address } -u #{ username } -p #{ password } }
    when 'SSH'
      Net::SSH.start(ip_address, username, password: password, port: 2222, timeout: 10) do |ssh|
        # Test connection and automatically close
      end
    end
  rescue
    raise "The instance is not publicly accessible on #{ ip_address } via #{ remote_client }."
  end
end


Then /^Connect to instance with floating IP (.+) via (.+)$/ do |floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  begin
    case remote_client.upcase
    when 'RDP'
      image_name = ServerConfigFile.operating_systems.grep(/windows/i)
      username   = ServerConfigFile.username(image_name)
      password   = ServerConfigFile.password(image_name)

      %x{ rdesktop #{ ip_address } -u #{ username } -p #{ password } }
    when 'SSH'
      image_name = ServerConfigFile.operating_systems.grep(/ubuntu/i)
      username   = ServerConfigFile.username(image_name)
      password   = ServerConfigFile.password(image_name)

      Net::SSH.start(ip_address, username, password: password, port: 2222, timeout: 10) do |ssh|
        # Test connection and automatically close
      end
    end
  rescue
    raise "The instance is not publicly accessible on #{ ip_address } via #{ remote_client }."
  end
end


Then /^Fail connecting to (.+) instance with floating IP (.+) via (.+)$/ do |image_name, floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  username = ServerConfigFile.username(image_name)
  password = ServerConfigFile.password(image_name)

  begin
    case remote_client.upcase
    when 'RDP'
      %x{ rdesktop #{ ip_address } -u #{ username } -p #{ password } }
    when 'SSH'
      Net::SSH.start(ip_address, username, password: password, port: 2222, timeout: 10) do |ssh|
        # Test connection and automatically close
      end
    end
    raise "The instance is still publicly accessible on #{ ip_address } via #{ remote_client }."
  rescue
  end
end


Then /^Fail connecting to instance with floating IP (.+) via (.+)$/ do |floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  begin
    case remote_client.upcase
    when 'RDP'
      image_name = ServerConfigFile.operating_systems.grep(/windows/i)
      username   = ServerConfigFile.username(image_name)
      password   = ServerConfigFile.password(image_name)

      %x{ rdesktop #{ ip_address } -u #{ username } -p #{ password } }
    when 'SSH'
      image_name = ServerConfigFile.operating_systems.grep(/ubuntu/i)
      username   = ServerConfigFile.username(image_name)
      password   = ServerConfigFile.password(image_name)

      Net::SSH.start(ip_address, username, password: password, port: 2222, timeout: 10) do |ssh|
        # Test connection and automatically close
      end
    end
    raise "The instance is still publicly accessible on #{ ip_address } via #{ remote_client }."
  rescue
  end
end


Then /^Fetch a list of device files on the instance with floating IP (.+)$/ do |floating_ip|
  row        = @current_page.floating_ip_row( id: floating_ip )
  ip_address = row.find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  # Parse the image name from the instance column value
  instance_name = row.find('.instance').text
  image_name    = instance_name.scan(/\((.+)\)/).flatten.first

  username = ServerConfigFile.username(image_name)
  password = ServerConfigFile.password(image_name)

  begin
    Net::SSH.start(ip_address, username, password: password, port: 2222, timeout: 10) do |ssh|
      @device_file_list = ssh.exec!('ls -1 /dev/vc*').split
    end
  rescue
    raise "Cannot fetch list of device files from #{ ip_address }."
  end
end


Then /^A new device file should have been created on the instance with floating IP (.+)$/ do |floating_ip|
  row        = @current_page.floating_ip_row( id: floating_ip )
  ip_address = row.find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  # Parse the image name from the instance column value
  instance_name = row.find('.instance').text
  image_name    = instance_name.scan(/\((.+)\)/).flatten.first

  username = ServerConfigFile.username(image_name)
  password = ServerConfigFile.password(image_name)
  changed_device_file_list = []

  begin
    Net::SSH.start(ip_address, username, password: password, port: 2222, timeout: 10) do |ssh|
      changed_device_file_list = ssh.exec!('ls -1 /dev/vc*').split
    end

    if (changed_device_file_list - @device_file_list).count != 1
      raise "Cannot ensure that a new device file has been created on the instance. " +
            "Expected count is #{ @device_file_list.count + 1 }. " +
            "Current count is #{ changed_device_file_list.count }."
    end
  rescue
    raise "Cannot fetch list of device files from #{ ip_address }."
  end
end
