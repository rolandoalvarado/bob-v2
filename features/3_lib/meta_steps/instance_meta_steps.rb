Then /^[Tt]he instance should be resized$/ do
  old_flavor = @instance.flavor
  step %{
    * The instance #{ @instance.id } should not have flavor #{ old_flavor }
  }
end

Then /^[Tt]he instance will be Created$/ do
  step "The instances table should include the text #{ @instance_name }"
end

Then /^[Tt]he instance will be Not Created$/ do
  step "The instances table should not include the text #{ @instance_name }"
end
