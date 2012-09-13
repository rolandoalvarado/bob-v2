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


Step /^A new device file should have been created on the instance named (.+) in project (.+)$/ do |instance_name, project_name|
  row        = @current_page.associated_floating_ip_row( name: instance_name )
  ip_address = row.find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  # Parse the image name from the instance column value
  instance_name = row.find('.instance').text
  image_name    = instance_name.scan(/\((.+)\)/).flatten.first

  # If the above fails, get the image name from the compute service
  if image_name.blank?
    project    = IdentityService.session.tenants.find { |i| i.name == project_name }
    raise "#{ project_name } couldn't be found!" unless project
    ComputeService.session.set_tenant project
    instance   = ComputeService.session.instances.find { |i| i.name == instance_name }
    image      = ImageService.session.images.find { |i| i.id == instance.image['id'] }
    image_name = image.name
  end

  username = ServerConfigFile.username(image_name)

  delta_time       = ((Time.now - @time_started) / 60).ceil
  device_file_list = []

  private_key = ComputeService.session.private_keys[test_keypair_name]
  raise "Couldn't find private key for keypair '#{ test_keypair_name }'!" unless private_key

  if instance.addresses.first[1].count  < 2
    instance = ComputeService.session.ensure_instance_is_rebooted_and_active(project, instance)
  end

  raise "Couldn't find public ip for instance '#{ instance_name }'!" unless instance.addresses.first[1].count > 1

  begin
    Net::SSH.start(ip_address, username, port: 2222, timeout: 30, key_data: [ private_key ]) do |ssh|
      # Get a list of all device /dev/vd* files modified/created from x minutes ago
      device_file_list = ssh.exec!("find /dev/vd* -mmin -#{ delta_time }").split
    end

    if device_file_list.empty?
      raise "No new device file has been created on the instance."
    end
  rescue => e
    raise "Cannot fetch list of device files from #{ ip_address }. " +
          "The error returned was: #{ e.inspect }"
  end
end

Step /^Ensure the instance named (.+) in project (.+) has an accessible public ip$/ do |instance_name, project_name|
  project    = IdentityService.session.tenants.find { |i| i.name == project_name }
  raise "#{ project_name } couldn't be found!" unless project
  ComputeService.session.set_tenant project
  instance   = ComputeService.session.instances.find { |i| i.name == instance_name }
  raise "#{ instance_name } couldn't be found!" unless instance

  #Reboot instance to make sure it has an external ip address
  if instance.addresses.first[1].count  < 2
    instance = ComputeService.session.ensure_instance_is_rebooted_and_active(project, instance)
  end

  raise "Couldn't find public ip for instance '#{ instance_name }'!" unless instance.addresses.first[1].count > 1
end


Step /^Connect to the instance named (.+) in project (.+) via (SSH|RDP)$/ do |instance_name, project_name, remote_client|
  row         = @current_page.associated_floating_ip_row( name: instance_name )
  ip_address  = row.find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  project     = IdentityService.session.tenants.find { |p| p.name == project_name }
  raise "#{ project_name } couldn't be found!" unless project

  ComputeService.session.set_tenant project
  instance    = ComputeService.session.instances.find { |i| i.name == instance_name }
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  image       = ImageService.session.images.find { |i| i.id == instance.image['id'] }
  raise "Couldn't find image for instance #{ instance_name }!" unless image
  image_name  = image.name

  username    = ServerConfigFile.username(image_name)

  remote_client_connection( remote_client, ip_address, username )
end


Step /^Ensure that a keypair named (.+) exists$/ do |keypair_name|
  ComputeService.session.ensure_keypair_exists keypair_name
end

Step /^Ensure that the user with credentials (.+)\/(.+) has a keypair named (.+)$/ do |username, password, key_name|
  # Keypairs are user-scoped, thus the need to login to the compute service
  # with the current user's credentials.
  ComputeService.session.set_credentials(username, password)
  ComputeService.session.ensure_keypair_exists(key_name)
end
