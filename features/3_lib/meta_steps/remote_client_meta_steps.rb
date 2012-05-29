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
  ip_address = @current_page.floating_ip_row( id: floating_ip ).text
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
  ip_address = @current_page.floating_ip_row( id: floating_ip ).text
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
