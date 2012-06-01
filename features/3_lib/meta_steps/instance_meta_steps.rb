Then /^The instance will be created$/i do
  step "The instances table should include the text #{ @instance_name }"
end

Then /^The instance will be not created$/i do
  step "The instances table should not include the text #{ @instance_name }"
end

Then /^Ensure that the an instance is a member of the default security group$/ do
  compute_service = ComputeService.session
  compute_service.ensure_active_instance_count(@project, 1)
end

Then /^Ensure that the instance is a member of the (.+) security group$/ do |security_group|
  compute_service = ComputeService.session
  compute_service.ensure_active_instance_count(@project, 1)
end
