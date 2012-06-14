Then /^Ensure that (.+) security group exist$/i do |security_group|
  compute_service = ComputeService.session
  security_group  = compute_service.find_security_group_by_name(@project, security_group)

  if security_group
    compute_service.ensure_project_security_group_count(@project, security_group.count)  
  else
    raise "Security Group couldn't be found!"
  end
  
  EnvironmentCleaner.register(:project, @project.id)

  @security_group = security_group
end


Then /^Ensure that (.+) security group does not exist$/i do |security_group|
  compute_service = ComputeService.session
  compute_service.ensure_project_security_group_count(@project, 0)  
end

Then /^Ensure that a security group named Web Servers exist$/i do
  compute_service = ComputeService.session
  security_group_attrs = CloudObjectBuilder.attributes_for(
                      :security_group,
                      :name     => Unique.name('Web Servers'),
                      :description    => ('Web Servers Security Group')
                    )
  new_security_group  = compute_service.create_security_group(@project, security_group_attrs)

  @new_security_group = new_security_group
end

Then /^Ensure that a security group named default exist$/i do
  compute_service = ComputeService.session
  security_group_attrs = CloudObjectBuilder.attributes_for(
                      :security_group,
                      :name     => Unique.name('default'),
                      :description    => ('Default Security Group')
                    )
  default_security_group  = compute_service.create_security_group(@project, security_group_attrs)

  @default_security_group = default_security_group
end

Then /^the security group rules will be Added$/i do

  raise ("there is no security group value") if @security_group == nil
  
  #check protocol
  field     'list ip protocol'               '#security-group-rules-list div.ip-protocoll'  
  field     'list from port'                 '#security-group-rules-list div.from-port'   
  field     'list to port'                   '#security-group-rules-list div.to-port'   
  field     'list cidr'                      '#security-group-rules-list div.cidr'   

  #check protocol
  protocol = @security_group[:protocol].downcase
  if protocol != "(any)" 
    value = @current_page.send("list ip protocol field").get
    if value != protocol
      raise "The ip protocol field should be #{protocol}, but it's #{value}"      
    end
  end

  from_port = @security_group[:from_port].downcase
  if protocol != "(random)" || protocol != "(any)" 
    value = @current_page.send("list from port field").get
    if value != protocol
      raise "The from port field should be #{from_port}, but it's #{value}"      
    end
  end   

  to_port = @security_group[:to_port].downcase
  if protocol != "(random)" || protocol != "(any)"  
    value = @current_page.send("list to port field").get
    if value != protocol
      raise "The to port should be #{to_port}, but it's #{value}"      
    end
  end   

  cidr = @security_group[:cidr].downcase
  if protocol != "(random)" || protocol != "(any)"  
    value = @current_page.send("list cidr field").get
    if value != protocol
      raise "The cidr field should be #{cidr}, but it's #{value}"      
    end
  end   

end

Then /^the security group rules will be Not Added$/i do
  begin
    value = @current_page.send("list_ip_protocol_field").get
  rescue
    #If exception occured, it's right 
  end
  if value != nil
    raise "The security group should not be added. but it's #{value}"
  end
end


Step /^Ensure that a security group rule exists for project (.+)$/ do |project_name|
  project = IdentityService.session.find_project_by_name(project_name)
  raise "#{ project_name } couldn't be found!" unless project

  ComputeService.session.ensure_security_group_rule project
end
