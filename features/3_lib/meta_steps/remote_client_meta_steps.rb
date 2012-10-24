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
      Net::SSH.start(ip_address, username, password: password, port:  22, timeout: 10, user_known_hosts_file: '/dev/null') do |ssh|
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

      Net::SSH.start(ip_address, username, password: password, port: 22, timeout: 10, user_known_hosts_file: '/dev/null') do |ssh|
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
      Net::SSH.start(ip_address, username, password: password, port: 22, timeout: 10, user_known_hosts_file: '/dev/null') do |ssh|
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

      Net::SSH.start(ip_address, username, password: password, port: 22, timeout: 10, user_known_hosts_file: '/dev/null') do |ssh|
        # Test connection and automatically close
      end
    end
    raise "The instance is still publicly accessible on #{ ip_address } via #{ remote_client }."
  rescue
  end
end


Step /^A new device file should have been created on the instance named (.+) in project (.+)$/ do |instance_name, project_name|
  row         = @current_page.associated_floating_ip_row( name: instance_name )
  external_ip  = row.find('.public-ip').text
  raise "No public external IP found for instance!" if external_ip.empty?

  internal_ip = row.find('.ip-address').text
  raise "No public internal IP found for instance!" if internal_ip.empty?
  

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

  options = {
    port: 22,
    timeout: 30,
    key_data: [ private_key ],
    user_known_hosts_file: '/dev/null'
  }

  begin
    remote_client_check_volume(external_ip, username, delta_time, options)
  rescue
    begin
      remote_client_check_volume(internal_ip, username, delta_time, options)
    rescue => e
      raise "Cannot fetch list of device files from both #{ external_ip } and #{ internal_ip }. " +
            "The error returned was: #{ e.inspect }"
    end

  end
end

Step /^Ensure the instance named (.+) in project (.+) has an accessible public ip$/ do |instance_name, project_name|
  project    = IdentityService.session.tenants.find { |i| i.name == project_name }
  raise "#{ project_name } couldn't be found!" unless project
  ComputeService.session.set_tenant project
  instance   = ComputeService.session.instances.find { |i| i.name == instance_name }
  raise "#{ instance_name } couldn't be found!" unless instance

  raise "Couldn't find public ip for instance '#{ instance_name }'!" unless instance.addresses.first[1].count > 1
end


Step /^Connect to the instance named (.+) in project (.+) via (SSH|RDP)$/ do |instance_name, project_name, remote_client|
  row         = @current_page.associated_floating_ip_row( name: instance_name )
  external_ip  = row.find('.public-ip').text
  raise "No public external IP found for instance!" if external_ip.empty?

  internal_ip = row.find('.ip-address').text
  raise "No public internal IP found for instance!" if internal_ip.empty?

  project     = IdentityService.session.tenants.find { |p| p.name == project_name }
  raise "#{ project_name } couldn't be found!" unless project

  ComputeService.session.set_tenant project
  instance    = ComputeService.session.instances.find { |i| i.name == instance_name }
  raise "Instance #{ instance_name } couldn't be found!" unless instance

  image       = ImageService.session.images.find { |i| i.id == instance.image['id'] }
  raise "Couldn't find image for instance #{ instance_name }!" unless image
  image_name  = image.name

  username    = ServerConfigFile.username(image_name)

  retried = false
  begin
    remote_client_connection( remote_client, external_ip, internal_ip, username )
  rescue => e
    unless retried
      # Reboot server then attempt reconnection once
      retried = true
      instance.reboot('HARD')
      sleep(ConfigFile.wait_short) until instance.reload.state == 'ACTIVE'
      retry
    else
      raise e
    end
  end
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
