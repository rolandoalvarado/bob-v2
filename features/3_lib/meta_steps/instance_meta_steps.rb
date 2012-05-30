Then /^The instance will be created$/i do
  step "The instances table should include the text #{ @instance_name }"
end

Then /^The instance will be not created$/i do
  step "The instances table should not include the text #{ @instance_name }"
end
