Step /^All Edit User buttons should not be visible$/ do
  if @current_page.has_content?("#user-list a.edit")
    raise "Edit user buttons should not be visible, but they are."
  end
end


Then /^(A|An) (.+) element should be visible$/i do |a_or_an, element_name|
  element_name = element_name.split.join('_').downcase
  unless @current_page.send("has_#{ element_name }_element?")
    raise "#{ a_or_an.capitalize } '#{ element_name.gsub('_',' ') }' element should be visible, but it is not."
  end
end


Then /^A new window should show the instance's VNC console$/ do
  unless @current_page.has_popup_window?('noVNC')
    raise "A new window with the instance's VNC console was not shown!"
  end
end


Then /^Check the (\d+)(?:st|nd|rd|th) item in the (.+) checklist$/ do |item_number, list_name|
  list_name = list_name.split.join('_').downcase
  checkbox  = @current_page.send("#{ list_name }_checklist_items")[item_number.to_i - 1]
  checkbox.click unless checkbox.checked?
end


Then /^Check the (.+) checkbox$/ do |checkbox_name|
  checkbox_name = checkbox_name.split.join('_').downcase
  checkbox = @current_page.send("#{ checkbox_name }_checkbox")
  checkbox.click unless checkbox.checked?
end


Then /^Choose the (\d+)(?:st|nd|rd|th) item in the (.+) radiolist$/ do |item_number, list_name|
  list_name = list_name.split.join('_').downcase
  @current_page.send("#{ list_name }_radiolist_items")[item_number.to_i - 1].click
end


Then /^Choose the (\d+)(?:st|nd|rd|th) item in the (.+) dropdown$/ do |item_number, dropdown_name|
  dropdown_name = dropdown_name.split.join('_').downcase
  @current_page.send("#{ dropdown_name }_dropdown_items")[item_number.to_i - 1].click
end


Then /^Choose the item with text (.+) in the (.+) dropdown$/ do |item_text, dropdown_name|
  dropdown_name  = dropdown_name.split.join('_').downcase
  dropdown_items = @current_page.send("#{ dropdown_name }_dropdown_items")

  item = case item_text.downcase
         when '(none)'
           dropdown_items.find { |d| d.value.blank? }
         when '(any)'
           dropdown_items[1]
         else
           dropdown_items.find { |d| d.text == item_text }
         end

  if item
    item.click
  else
    raise "Couldn't find the dropdown option '#{ item_text }'."
  end
end

Then /^Clear the (.+) field$/i do |field_name|
  field_name = field_name.split.join('_').downcase
  @current_page.send("#{ field_name }_field").set ""
end


Then /^Click the context menu button for user (.+)$/ do |username|
  username = Unique.username(username)
  @current_page.context_menu_button(name: username).click
end

Then /^Click the (.+) link for user (.+)$/ do |link_name, username|
  username  = Unique.username(username)
  link_name = link_name.split.join('_').downcase

  @current_page.send("#{ link_name }_link", name: username).click
end


Then /^Click the Logout button if currently logged in$/i do
  @current_page ||= RootPage.new
  @current_page.visit                      # This removes any modal overlay
  unless @current_page.actual_url.empty?
    @current_page.logout_button.click if @current_page.has_no_login_form?
  end
end


Then /^Click the (.+) button$/ do |button_name|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button").click

  if button_name == 'login'
    @current_page = SecurePage.new
  end
end


Then /^Click the (.+) link$/ do |link_name|
  link_name = link_name.split.join('_').downcase
  @current_page.send("#{ link_name }_link").click

  page_name = link_name
  page_class_name = "#{ page_name.downcase.capitalize }Page"
  unless Object.const_defined?( page_class_name )
    raise "The #{ page_name } page (#{ page_class_name }) is not defined " +
          "anywhere in the pages directory. You may have misspelled " +
          "the page's name, or you may need to define a #{ page_class_name } " +
          "class somewhere in that directory."
  end
  @current_page = eval(page_class_name).new
end


Then /^Click the (.+) button for instance (.+)$/ do |button_name, instance_id|
  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    button_name = button_name.split.join('_').downcase
    @current_page.send("#{ button_name }_button", id: instance_id).click
  end
end


# Match "Click the <text1> button for volume <text2>",
# but not when $text2 starts with the string "snapshot named"
Then /^Click the (.+) button for volume (?:(?!snapshot named ))(.+)$/ do |button_name, volume_id|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button", id: volume_id).click
end

Then /^Click the (.+) link for security group (.+)$/ do |link_name, security_group_id|
  link_name = link_name.split.join('_').downcase
  @current_page.send("#{ link_name }_link", id: security_group_id).click
end

Then /^Click the (.+) button for security group (.+)$/ do |button_name, security_group_id|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button", id: security_group_id).click
end

Step /^Click the (delete|disable|edit) button for user (.+)$/ do |button_name, user_id|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button", id: user_id).click
end

Then /^Click the (.+) button for volume snapshot named (.+)$/ do |button_name, snapshot_name|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button", name: snapshot_name).click
end

Then /^Click the (.+) project$/ do |project_name|
  project_name.strip!
  @current_page.project_link( name: project_name ).click
  @current_page = ProjectPage.new
end

Step /^Click on the tile for project (.+)$/ do |project_name|
  project_name.strip!
  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    unless @current_page.has_tile_element?( name: project_name )
      raise "Couldn't find tile for project #{ project_name }!"
    else
      @current_page.tile_element( name: project_name ).click
    end
  end
end

Step /^Double\-click on the tile for project (.+)$/ do |project_name|
  project_name.strip!
  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    unless @current_page.has_tile_element?( name: project_name )
      raise "Couldn't find tile for project #{ project_name }!"
    else
      tile = @current_page.tile_element( name: project_name )
      @current_page.session.driver.browser.mouse.double_click(tile.native)
    end
  end
end

Step /^Double\-click on the tile for instance (.+)$/ do |instance_name|
  instance_name.strip!
  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    unless @current_page.has_tile_element?( name: instance_name )
      raise "Couldn't find tile for instance #{ instance_name }!"
    else
      tile = @current_page.tile_element( name: instance_name )
      @current_page.session.driver.browser.mouse.double_click(tile.native)
    end
  end
end

Then /^Click the (.+) tab$/ do |tab_name|
  tab_name = tab_name.split.join('_').downcase
  @current_page.send("#{ tab_name }_tab").click
end


Then /^Click the row for user with id (.+)$/i do |user_id|
  user_id.strip!
  @current_page.user_link(id: user_id).click
end

Then /^Click the row for security group with id (.+)$/i do |security_group_id|
  security_group_id.strip!
  @current_page.security_group_link(id: security_group_id).click
end

Step /^Click the context menu button of the volume named (.+)$/i do |volume_name|
  VolumeService.session.reload_volumes
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }

  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  @current_page.volume_context_menu_button(:id => volume['id']).click
end

Step /^Click the (attach|delete|detach) button of the volume named (.+)$/i do |button_name, volume_name|
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name && v['status'] == 'available' }
  raise "Couldn't find an available volume named '#{ volume_name }'" unless volume

  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_volume_button", id: volume['id']).click
end

Then /^Click the link for user with username (.+)$/i do |username|
  user = IdentityService.session.find_user_by_name(username.strip)
  raise "ERROR: I couldn't find a user with username '#{ username }'." unless user
  @current_page.user_link(user_id: user.id).click
end


Then /^Click the (.+) image$/ do |image_name|
  @current_page.image_element( name: image_name.strip ).click
end

Step /^Close the (.+) form$/i do |form_name|
  form_name = form_name.split.join('_').downcase
  @current_page.send("#{ form_name }_form").find('.close').click
end

Then /^Current page should be the (.+) page$/i do |page_name|
  @current_page = eval("#{ page_name.downcase.capitalize }Page").new
  unless @current_page.has_expected_path?
    raise "Expected #{ @current_page.expected_path } but another page was returned: #{ @current_page.actual_path }"
  end
end


Then /^Current page should(?:| still) have the (.+) (button|field|form|tile)$/ do |name, type|
  name = name.split.join('_').downcase
  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    unless @current_page.send("has_#{ name }_#{type}?")
      raise "Current page doesn't have a #{ name } #{ type }"
    end
  end
end

Step /^There should be project tile element for (.+)$/ do |project_name|
  type = 'tile'
  name = project_name.split.join('_').downcase
  unless @current_page.send("has_#{ name }_#{type}?")
    raise "Current page doesn't have a #{ name } #{ type }"
  end
end


Then /^Current page should have the correct path$/ do
  unless @current_page.has_expected_path?
    raise "Expected #{ @current_page.expected_path } but another page was returned: #{ @current_page.actual_path }"
  end
end


Then /^Current page should show the instance's console output$/ do
  unless @current_page.has_console_output_element?
    raise "Current page doesn't show the instance's console output."
  end
end


Then /^Current page should have the security groups$/ do
  unless @current_page.has_security_groups_element?
    raise "Current page doesn't have security groups."
  end
end


Then /^Current page should have the new collaborator$/ do
  unless @current_page.has_collaborator_element?
    raise "Current page doesn't have collaborator."
  end
end


Then /^Current page should have the users$/ do
  unless @current_page.has_users_element?
    raise "Current page doesn't have users."
  end
end


Then /^Current page should have the new security group rule$/ do
  unless @current_page.has_security_groups_element?
    raise "Current page doesn't have security groups."
  end
end

#Then /^Current page should have the new (.+) security group$/ do |security_group|
#  unless @current_page.has_security_groups_element?
#    raise "Current page doesn't have the new #{security_group} security group."
#  end
#end

Step /^Current page should display project details in the sidebar$/ do
  unless @current_page.has_project_element?
    raise "Current page doesn't have the #{project_name} details."
  end
end

Then /^Current page should have the (.+) graph$/ do |graph_name|
  graph_name = graph_name.to_s.downcase.split.join('_')
  unless @current_page.send(:"has_#{ graph_name }_graph?")
    raise "Current page doesn't have the #{ graph_name } graph."
  end
end

Then /^Current page should have the (.+) security group$/ do |security_group|
  unless @current_page.has_security_groups_element?
    raise "Current page doesn't have the #{security_group} security group."
  end
end

Then /^Drag the(?:| instance) flavor slider to a different flavor$/ do
  @current_page.session.execute_script %{
    var slider = $('#flavor-slider'),
      value = parseInt(slider.slider('option', 'value')),
      min = parseInt(slider.slider('option', 'min'));

    if(value == min) { value = value + 1; }
    else if(value > min) { value = min; }
    slider.slider('option', 'value', value);
    slider.trigger('slide', { 'value': value });
  }
end

Then /^Drag the(?:| instance) flavor slider to the (.+)$/ do |flavor|
  flavors = %w[ m1.small m1.medium m1.large m1.xlarge ]

  if flavor.downcase != '(any)'
    value = flavors.index(flavor)

    @current_page.session.execute_script %{
      var slider = $('#flavor-slider');
      slider.slider('option', 'value', #{ value });
      slider.trigger('slide', { 'value': #{ value } });
    }
  end
end


Then /^Fill in the (.+) field with (.+)$/ do |field_name, value|
  value      = value.gsub(/^\([Nn]one\)$/, '')
  field_name = field_name.split.join('_').downcase

  case field_name
  when 'username'
    value = Unique.username(value) unless value.empty?
  end

  @current_page.send("#{ field_name }_field").set value
end


Then /^Select OS image (.+) item from the images radiolist$/ do |image_name|
 if image_name == "(Any)"
   step "Choose the 1st item in the images radiolist"
 else
   step "Click the #{ image_name } image"
 end
end


Then /^Select flavor (.+) item from the flavor slider$/ do |flavor|
 if flavor.downcase == "(any)"
   #nothing
 else
   pending
 end
end


Then /^Select keypair (.+) item from the keypair dropdown$/ do |keypair|
 if keypair.downcase == "(any)"
   #nothing
 elsif keypair.downcase  == "(none)"
   #nothing
 else
   pending
 end
end


Then /^Select instance count (.+)$/ do |count|
 if count.downcase == "(any)"
   #nothing
 else
   pending
 end
end

Then /^Select Security Group (.+) item from the security group checklist$/i do |security_group|
 if security_group.downcase == "(any)"
   #nothing
 elsif security_group.downcase == "(none)"
   steps %{
     * Uncheck all items in the security groups checklist
   }
 else
   pending
 end
end


Then /^Set instance name field with (.+)$/ do |instance_name|
  if instance_name.downcase == "(any)"
    step "Fill in the server name field with #{Unique.name('Instance')}"
  elsif instance_name.downcase  != "(none)"
    step "Fill in the server name field with #{instance_name}"
  end
end


Then /^Set the ((?:from|to) port) field to (.+)$/ do |field_name, port_number|
  field_name = field_name.downcase.split.join('_')
  value = case port_number.downcase
          when '(random)' then (rand(65534) + 1).to_s
          when '(none)'   then ''
          else port_number
          end
  @current_page.send("#{ field_name }_field").set(value)
end

Step /^Store the private key for keypair (.+)$/i do |key_name|
  key_value = @current_page.keypair_private_key_field.value
  ComputeService.session.private_keys[key_name] = key_value
end

Then /^The (.+) form should be visible$/ do |form_name|
  form_name = form_name.split.join('_').downcase
  unless @current_page.send("has_#{ form_name }_form?")
    raise "The '#{ form_name.gsub('_',' ') }' form should be visible, but it's not."
  end
end


Then /^The (.+) form has an error message$/ do |form_name|
  name = form_name.split.join('_').downcase
  if @current_page.send("has_no_#{ name }_error_message?")
    raise "Expected the #{ form_name } form to have an error message, but none was found."
  end
end


Then /^The (.+) form should not be visible$/ do |form_name|
  name = form_name.split.join('_').downcase
  unless @current_page.send("has_no_#{ name }_form?")
    raise "The #{ form_name } form should not be visible, but it is."
  end
end


Then /^The (.+) table should include the text (.+)$/ do |table_name, text|
  table_name = table_name.split.join('_').downcase
  unless @current_page.send("#{ table_name }_table").has_content?(text)
    raise "Couldn't find the text '#{ text }' in the #{ table_name } table."
  end
end


Then /^The (.+) table should not include the text (.+)$/ do |table_name, text|
  table_name = table_name.split.join('_').downcase
  if @current_page.send("#{ table_name }_table").wait_for_content_to_disappear(text)
    raise "The text '#{ text }' should not be in the #{ table_name } table, but it is."
  end
end

Step /^The delete button of the volume named (.+) should not be visible$/ do |volume_name|
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }
  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  unless @current_page.send("has_no_delete_volume_button?", id: volume['id'])
    raise "The delete button of the volume #{ volume_name } should not be visible, but it is!"
  end
end

Then /^The (.+) button should be disabled$/ do |button_name|
  button_name = button_name.split.join('_').downcase
  unless @current_page.send("has_disabled_#{ button_name }_button?")
    raise "Couldn't find disabled #{ button_name } button."
  end
end

Then /^The (.+) dropdown should not have the item with text (.+)$/ do |dropdown_name, item_text|
  dropdown_name = dropdown_name.split.join('_').downcase
  if @current_page.send("#{ dropdown_name }_dropdown_items").find { |d| d.text == item_text }
    raise "Expected to not find the dropdown option '#{ item_text }'."
  end
end

Then /^The (.+) link should be disabled$/ do |link_name|
  link_name = link_name.split.join('_').downcase
  unless @current_page.send("has_disabled_#{ link_name }_link?")
    raise "Couldn't find disabled #{ link_name } link."
  end
end

Then /^The (.+) link should be disabled with (.+)$/i do |link_name,name|
  link_name = link_name.split.join('_').downcase

  unless @current_page.send("has_disabled_#{ link_name.gsub(' ','_') }_link?", name: name)
    raise "Couldn't find disabled #{ link_name } link."
  end
end

Then /^The (.+) tab should be disabled$/ do |tab_name|
  tab_name = tab_name.split.join('_').downcase
  unless @current_page.send("has_disabled_#{ tab_name }_tab?")
    raise "Couldn't find disabled #{ tab_name } tab."
  end
end


Then /^The (.+) user row should be visible$/ do |username|
  unless @current_page.has_user_row?( name: username )
    raise "The row for user #{ username } should exist, but it doesn't."
  end
end


Step /^(?:A|The) Floating IP should be associated to instance (.+)$/i do |instance_name|
  sleeping(1).seconds.between_tries.failing_after(15).tries do
    unless @current_page.has_associated_floating_ip_row?( name: instance_name )
      raise "Couldn't find a floating IP to be associated to instance #{ instance_name }!"
    end
  end
end


Step /^(?:A|The) floating IP should not be associated to instance (.+)$/i do |instance_name|
  sleeping(1).seconds.between_tries.failing_after(15).tries do
    if @current_page.has_associated_floating_ip_row?( name: instance_name )
      raise "Found a floating IP to be associated to instance #{ instance_name }!"
    end
  end
end


Then /^The instance (.+) should be performing task (.+)$/ do |instance_id, task|
  sleeping(1).seconds.between_tries.failing_after(15).tries do
    unless @current_page.instance_row( id: instance_id ).find('.task').text.include?(task)
      raise "Instance #{ instance_id } is not shown as performing task #{ task }."
    end
  end
end


Then /^The instance (.+) should be shown as rebooting$/ do |instance_id|
  sleeping(1).seconds.between_tries.failing_after(15).tries do
    unless @current_page.instance_row( id: instance_id ).find('.task').text.include?('rebooting')
      raise "Instance #{ instance_id } is not shown as rebooting."
    end
  end
end


Then /^The instance (.+) should be shown as resuming$/ do |instance_id|
  unless @current_page.instance_row( id: instance_id ).find('.task').has_content?('resuming')
    raise "Instance #{ instance_id } is not shown as resuming."
  end
end


Then /^The instance (.+) should be shown as suspending$/ do |instance_id|
  unless @current_page.instance_row( id: instance_id ).find('.task').has_content?('suspending')
    raise "Instance #{ instance_id } is not shown as suspending."
  end
end


Then /^The instance ((?:(?!named )).+) should be (?:in|of) (.+) status$/ do |instance_id, status|
  sleeping(1).seconds.between_tries.failing_after(20).tries do
    unless @current_page.instance_row( id: instance_id ).find('.status').has_content?(status.upcase.gsub(' ', '_'))
      raise "Instance #{ instance_id } does not have or took to long to become #{ status } status."
    end
  end
end


Step /^The instance named (.+) should be (?:in|of) (.+) status$/ do |instance_name, expected_status|
  # TODO To prevent conflict with other instance steps, temporarily forgo changing the selector,
  # and instead finding it directly from the page object.
  selector = "//*[@id='instances-list']//*[contains(@class, 'name') and contains(text(), \"#{ instance_name }\")]/.."
  row      = @current_page.find_by_xpath(selector)

  actual_status = row.find('.status').text.strip
  unless actual_status == expected_status.upcase.gsub(' ', '_')
    raise "Instance #{ instance_name } is not or took too long to become #{ expected_status }. " +
          "Current status is #{ actual_status }."
  end
end


Then /^The instance (.+) should not have flavor (.+)$/ do |instance_id, flavor_name|
  if @current_page.instance_row( id: instance_id ).find('.flavor').has_content?(flavor_name)
    raise "Expected flavor of instance #{ instance_id } to change. " +
          "Current flavor is #{ flavor_name }."
  end
end


Step /^The item with text (.+) should be default in the (.+) dropdown$/ do |item_text, dropdown_name|
  dropdown_name = dropdown_name.split.join('_').downcase
  if item = @current_page.send("#{ dropdown_name }_dropdown_items").find { |d| d.text == item_text }
    unless item[:selected] || item[:default]
      raise "Expected option '#{ item_text }' to be the default for the #{ dropdown_name } dropdown."
    end
  else
    raise "Couldn't find the dropdown option '#{ item_text }'."
  end
end


Step /^Click the (.+) button for the user named (.+)$/ do |button_name, username|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_user_button", name: username).click
end

Then /^The volume named (.+) should be (?:in|of) (.+) status$/ do |volume_name, status|
  VolumeService.session.reload_volumes
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }
  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  status.downcase!
  sleeping(1).seconds.between_tries.failing_after(15).tries do
    volume_row    = @current_page.volume_row( id: volume['id'] ).find('.volume-status')
    volume_status = volume_row.text.to_s.strip.downcase
    unless volume_status == status
      raise "Volume #{ volume_name } took to long to become #{ status }."
    end
  end
end

Then /^The volume named (.+) should be attached to the instance named (.+)$/ do |volume_name, instance_name|
  VolumeService.session.reload_volumes
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }
  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    unless @current_page.has_volume_row?(id: volume['id'])
      raise "Could not find row for the volume named #{ volume_name }!"
    end
  end

  sleeping(ConfigFile.wait_short).seconds.between_tries.failing_after(ConfigFile.repeat_short).tries do
    attachment = @current_page.volume_row(id: volume['id']).find('.attachments').text.to_s.strip
    if attachment != instance_name
      raise "Expected volume #{ volume_name } to be attached to instance #{ instance_name }, " +
            "but it's not."
    end
  end
end

Then /^The volume named (.+) should not be attached to the instance named (.+)$/ do |volume_name, instance_name|
  VolumeService.session.reload_volumes
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }

  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  sleeping(1).seconds.between_tries.failing_after(15).tries do
    unless @current_page.has_volume_row?(id: volume['id'])
      raise "Could not find row for the volume named #{ volume_name }!"
    end

    attachment = @current_page.volume_row(id: volume['id']).find('.attachments').text.to_s.strip
    if attachment == instance_name
      raise "Expected volume #{ volume_name } to not be attached to instance #{ instance_name }, but it is."
    end
  end
end

Step /^The volume named (.+) should not be attached to the instance named (.+) in project (.+)$/ do |volume_name, instance_name, project_name|
  project = IdentityService.session.find_tenant_by_name(project_name)
  raise "Couldn't find a project named '#{ project_name }'" unless project

  instance = ComputeService.session.find_instance_by_name(project, instance_name)
  raise "Couldn't find an instance named '#{ instance_name }'" unless instance

  VolumeService.session.reload_volumes
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }

  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  sleeping(1).seconds.between_tries.failing_after(15).tries do
    unless @current_page.has_volume_row?(id: volume['id'])
      raise "Could not find row for the volume named #{ volume_name }!"
    end

    attachment_id = @current_page.volume_row(id: volume['id']).find('.attachments')[:title]
    if attachment_id == instance.id
      raise "Expected volume #{ volume_name } to not be attached to instance #{ instance_name }, but it is."
    end
  end
end


Then /^The (.+) link should be visible$/ do |link_name|
  link_name = link_name.split.join('_').downcase
  unless @current_page.send("has_#{ link_name }_link?")
    raise "The '#{ link_name.gsub('_',' ') }' link should be visible, but it's not."
  end
end


Then /^The (.+) link should not be visible$/ do |link_name|
  link_name = link_name.split.join('_').downcase
  if @current_page.send("has_#{ link_name }_link?")
    raise "The '#{ link_name.gsub('_',' ') }' link should not be visible, but it is."
  end
end

Step /^The (.+) button should not be visible$/ do |button_name|
  button_name = button_name.split.join('_').downcase
  if @current_page.send("has_#{ button_name }_button?")
    raise "The '#{ button_name.gsub('_',' ') }' button should not be visible, but it is."
  end
end

Step /^The Context Menu button for the user named (.+) should not be visible$/i do |username|
  if @current_page.send("has_context_menu_button?", name: username)
    raise "The context menu button for user #{ username } should not be visible, but it is."
  end
end

Then /^The (.+) message should be visible$/ do |message_name|
  message_name = message_name.split.join('_').downcase
  unless @current_page.send("has_#{ message_name }_message?")
    raise "The '#{ message_name.gsub('_',' ') }' message should be visible, but it's not."
  end
end


Then /^The (.+) message should not be visible$/ do |message_name|
  message_name = message_name.split.join('_').downcase
  if @current_page.send("has_#{ message_name }_message?")
    raise "The '#{ message_name.gsub('_',' ') }' message should not be visible, but it is."
  end
end


Then /^The (.+) span should be visible$/ do |span_name|
  span_name = span_name.split.join('_').downcase
  unless @current_page.send("has_#{ span_name }_span?")
    raise "The '#{ span_name.gsub('_',' ') }' span should be visible, but it's not."
  end
end


Then /^The (.+) span should not be visible$/ do |span_name|
  span_name = span_name.split.join('_').downcase
  if @current_page.send("has_#{ span_name }_span?")
    raise "The '#{ span_name.gsub('_',' ') }' span should not be visible, but it is."
  end
end

Then /^The (.+) user should be visible$/ do |user_name|
  unless @current_page.has_user_name_element?( name: user_name )
    raise "The user '#{ user_name }' should be visible, but it's not."
  end
end


Then /^The (.+) project should be visible$/ do |project_name|
  unless @current_page.has_project_link?( name: project_name )
    raise "The project '#{ project_name }' should be visible, but it's not."
  end
end

Step /^The (.+) project row should be visible$/ do |project_name|
  sleeping(1).seconds.between_tries.failing_after(15).tries do
    unless @current_page.has_project_row?( name: project_name )
      raise "The project '#{ project_name }' row should be visible, but it's not."
    end
  end
end

Step /^The (.+) project details should be visible in the sidebar$/ do |project_name|
  unless @current_page.has_project_details_element?( name: project_name )
    raise "The project '#{ project_name }' should be visible, but it's not."
  end
end


Step /^The (.+) project tile should be visible$/ do |project_name|
  unless @current_page.has_tile_element?( name: project_name )
    raise "The tile for project '#{ project_name }' should be visible, but it's not."
  end
end

Step /^There should be (\d+) tiles visible in the page$/ do |tile_count|
  tile_count = tile_count.to_i
  unless @current_page.send("has_no_tile_element?")
    raise "There should be #{ tile_count } tile visible, but it is."
  end
end


Then /^The (.+) project should not be visible$/ do |project_name|
  if @current_page.has_project_row?( name: project_name )
    raise "The project '#{ project_name }' should not be visible, but it is."
  end
end


Then /^The (.+) table should have (\d+) (?:row|rows)$/ do |table_name, num_rows|
  table_name      = table_name.split.join('_').downcase
  table           = @current_page.send("#{ table_name }_table")
  actual_num_rows = if table.has_no_css_selector?('td.empty-table')
                      table.has_css_selector?('tbody tr') ? table.all('tbody tr').count : table.all('tr').count
                    else
                      0
                    end
  num_rows        = num_rows.to_i

  if actual_num_rows != num_rows
    raise "Expected #{ num_rows } rows in the #{ table_name } table, but counted #{ actual_num_rows }."
  end
end


Step /^The (.+) table's last row should include the text (.+)$/ do |table_name, text|
  table_name = table_name.split.join('_').downcase
  table_rows = @current_page.send("#{ table_name }_table").all('tbody tr')
  unless table_rows.last.has_content?(text)
    raise "Couldn't find the text '#{ text }' in the last row of the #{ table_name } table."
  end
end


Then /^The (.+) table's last row should not include the text (.+)$/ do |table_name, text|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    table_name = table_name.split.join('_').downcase
    table_rows = @current_page.send("#{ table_name }_table").all('tbody tr')
    unless table_rows.last.has_no_content?(text)
      raise "Found the text '#{ text }' in the last row of the #{ table_name } table."
    end
  end
end

Then /^The volumes table should have a row for the volume named (.+)$/ do |volume_name|
  VolumeService.session.reload_volumes
  volume = VolumeService.session.volumes.find { |v| v['display_name'] == volume_name }
  raise "Couldn't find a volume named '#{ volume_name }'" unless volume

  unless @current_page.has_volume_row?( id: volume['id'] )
    raise "Expected to find a row for volume #{ volume_name } in the " +
          "volumes table, but couldn't find it."
  end
end

Then /^The volume snapshots table should have a row for the volume snapshot named (.+)$/ do |volume_snapshot_name|
  unless @current_page.has_volume_snapshot_row?( name: volume_snapshot_name )
    raise "Expected to find a row for volume snapshot #{ volume_snapshot_name } in the " +
          "volume snapshots table, but couldn't find it."
  end
end

Then /^The volume snapshots table should not have a row for the volume snapshot named (.+)$/ do |volume_snapshot_name|
  if @current_page.has_volume_snapshot_row?( name: volume_snapshot_name )
    raise "Expected not to find a row for volume snapshot #{ volume_snapshot_name } in the " +
          "volume snapshots table, but found it."
  end
end

Then /^Uncheck all items in the (.+) checklist$/ do |list_name|
  list_name = list_name.split.join('_').downcase
  checklist = @current_page.send("#{ list_name }_checklist_items")
  checklist.each do |checkbox|
    checkbox.click if checkbox.checked?
  end
end

Then /^Uncheck the (\d+)(?:st|nd|rd|th) item in the (.+) checklist$/ do |item_number, list_name|
  list_name = list_name.split.join('_').downcase
  checkbox  = @current_page.send("#{ list_name }_checklist_items")[item_number.to_i - 1]
  checkbox.click if checkbox.checked?
end

Then /^Uncheck the (.+) checkbox$/ do |checkbox_name|
  checkbox_name = checkbox_name.split.join('_').downcase
  checkbox = @current_page.send("#{ checkbox_name }_checkbox")
  checkbox.click if checkbox.checked?
end

Then /^Uncheck the (.+) checkbox with value (.+)$/ do |checkbox_name, value|
  checkbox_name = checkbox_name.split.join('_').downcase
  checkbox = @current_page.send("#{ checkbox_name }_checkbox", name: value)
  checkbox.click if checkbox.checked?
end


Then /^Visit the (.+) page$/ do |page_name|
  page_class_name = "#{ page_name.downcase.capitalize }Page"
  unless Object.const_defined?( page_class_name )
    raise "The #{ page_name } page (#{ page_class_name }) is not defined " +
          "anywhere in the pages directory. You may have misspelled " +
          "the page's name, or you may need to define a #{ page_class_name } " +
          "class somewhere in that directory."
  end
  @current_page = eval(page_class_name).new
  @current_page.visit
end

Then /^Wait (.+) second(?:s|)/i  do |wait_secs|
  sleep(wait_secs.to_i)
end

Then /^Wait for (\d+) (?:minute|minutes).*$/ do |number_of_minutes|
  sleep(60 * number_of_minutes.to_i)
end

Then /^Wait for (.+) to finish (.+)$/ do |object, action|
  begin
    node = @current_page.find('i.icon-repeat')
  rescue
    raise "The #{ object } took too long to finish #{ action }!"
  end
end

Step /^Write the contents of the (.+) field to file (.+)$/i do |field_name, filename|
  field_name = field_name.split.join('_').downcase
  field      = @current_page.send("#{ field_name }_field")

  File.open(filename.to_s, 'w') do |file|
    file.puts field.value
  end
end
