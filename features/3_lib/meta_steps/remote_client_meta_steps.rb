Then /^Connect to instance with floating IP (.+) via (.+)$/ do |floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).find('.public-ip').text
  raise "No public IP found for instance!" if ip_address.empty?

  begin
    case remote_client.upcase
    when 'RDP'
      %x{ rdesktop #{ ip_address } -u Administrator -p s3l3ct10n }
    when 'SSH'
      Net::SSH.start(ip_address, 'root', password: 's3l3ct10n', port: 2222, timeout: 10) do |ssh|
        # Test connection and automatically close
      end
    end
  rescue
    raise "The instance is not publicly accessible on #{ ip_address } via #{ remote_client }."
  end
end


Then /^Fail connecting to instance with floating IP (.+) via (.+)$/ do |floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).text
  raise "No public IP found for instance!" if ip_address.empty?

  begin
    case remote_client.upcase
    when 'RDP'
      %x{ rdesktop #{ ip_address } -u Administrator -p s3l3ct10n }
    when 'SSH'
      Net::SSH.start(ip_address, 'root', password: 's3l3ct10n', port: 2222) do |ssh|
        # Test connection and automatically close
      end
    end
    raise "The instance is still publicly accessible on #{ ip_address } via #{ remote_client }."
  rescue
  end
end


Then /^Fail connecting to instance on (.+) via (.+)$/ do |ip_address, remote_client|
  begin
    case remote_client.upcase
    when 'RDP'
      %x{ rdesktop #{ ip_address } -u Administrator -p s3l3ct10n }
    when 'SSH'
      Net::SSH.start(ip_address, 'root', password: 's3l3ct10n', port: 2222) do |ssh|
        # Test connection and automatically close
      end
    end
    raise "The instance is still publicly accessible on #{ ip_address } via #{ remote_client }."
  rescue
  end
end
