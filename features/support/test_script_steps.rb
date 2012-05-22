# NOTE: These are steps that are to be used from within other step definitions
# only. DO NOT USE WITHIN FEATURE FILES. If you are using these steps directly
# in the feature files, then you are doing something very wrong. Please refer
# to http://www.relaxdiego.com/2012/04/using-cucumber.html for a better
# understanding on how to organize steps.


#
# PLEASE ARRANGE ALPHABETICALLY when adding a new stepdef
#


include Anticipate

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
  dropdown_name = dropdown_name.split.join('_').downcase
  if item = @current_page.send("#{ dropdown_name }_dropdown_items").find { |d| d.text == item_text }
    item.click
  else
    raise "Couldn't find the dropdown option '#{ item_text }'."
  end
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


Then /^Click the [Ll]ogout button if currently logged in$/ do
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
end

Then /^Click the (.+) button for instance (.+)$/ do |button_name, instance_id|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button", id: instance_id).click
end

Then /^Click the (.+) project$/ do |project_name|
  project_name.strip!
  @current_page.project_link( name: project_name ).click
  @current_page = ProjectPage.new
end

Then /^Click the (.+) image$/ do |image_name|
  @current_page.image_element( name: image_name.strip ).click
end

Then /^Connect to instance with floating IP (.+) via (.+)$/ do |floating_ip, remote_client|
  ip_address = @current_page.floating_ip_row( id: floating_ip ).find('.public-ip').text
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
  rescue
    raise "The instance is not publicly accessible on #{ ip_address } via #{ remote_client }."
  end
end

Then /^Current page should be the (.+) page$/ do |page_name|
  @current_page = eval("#{ page_name.downcase.capitalize }Page").new
  unless @current_page.has_expected_path?
    raise "Expected #{ @current_page.expected_path } but another page was returned: #{ @current_page.actual_path }"
  end
end

Then /^Current page should have the (.+) (button|field|form)$/ do |name, type|
  name = name.split.join('_').downcase
  unless @current_page.send("has_#{ name }_#{type}?")
    raise "Current page doesn't have a #{ name } #{ type }"
  end
end

Then /^Current page should have the correct path$/ do
  unless @current_page.has_expected_path?
    raise "Expected #{ @current_page.expected_path } but another page was returned: #{ @current_page.actual_path }"
  end
end

Then /^Current page should show the instance.s console output$/ do
  unless @current_page.has_console_output_element?
    raise "Current page doesn't show the instance's console output."
  end
end

Then /^Delete the (.+) project$/ do |project_name|
  project_name.strip!
  @current_page.project_menu_button( name: project_name ).click

  begin
    delete_project_link = @current_page.delete_project_link( name: project_name )
  rescue
    raise "Expected a link to delete the project '#{ project_name }' but none was found."
  end

  delete_project_link.click
  @current_page.delete_confirmation_button.click

end

Then /^Drag the instance flavor slider to a different flavor$/ do
  @current_page.execute_script %{
    var slider = $('#flavor-slider'),
      value = slider.slider('option', 'value'),
      min = slider.slider('option', 'min'),
      max = slider.slider('option', 'max');

    // change value to min or max
    if(value > min) { slider.slider('option', 'value', min); }
    else if(value < max) { slider.slider('option', 'value', max); }
  }
end

Then /^Edit the (.+) project$/ do |project_name|
  project_name.strip!
  @current_page.project_menu_button( name: project_name ).click

  begin
    edit_project_link = @current_page.edit_project_link( name: project_name )
  rescue
    raise "Expected a link to edit the project '#{ project_name }' but none was found."
  end

  edit_project_link.click
  @current_page = ProjectPage.new
end

Then /^Ensure that a user with username (.+) and password (.+) exists$/ do |username, password|
  username           = Unique.username(username)
  @user_attrs        = CloudObjectBuilder.attributes_for(:user, :name => username, :password => password)
  @user_attrs[:name] = Unique.username(@user_attrs[:name])
  @user = IdentityService.instance.ensure_user_exists(@user_attrs)
  EnvironmentCleaner.register(:user, @user.id)
end

Then /^Ensure that a user with username (.+) does not exist$/ do |username|
  user = IdentityService.session.users.reload.find { |u| u.name == username }
  IdentityService.session.delete_user(user) if user
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

Then /^[Rr]egister project (.+) for deletion on exit$/ do |name|
  project = IdentityService.session.tenants.reload.find { |p| p.name == name }
  EnvironmentCleaner.register(:project, project.id) if project
end

Then /^[Rr]egister user (.+) for deletion on exit$/ do |username|
  user = IdentityService.session.users.reload.find { |u| u.name == username }
  EnvironmentCleaner.register(:user, user.id) if user
end

Then /^Select OS image (.+) item from the images radiolist$/ do |imagename|
 if imagename == "(Any)"
   step "Choose the 1st item in the images radiolist"
 else
   pending
 end
end

Then /^Select flavor (.+) item from the flavor slider$/ do |flavor|
 if flavor == "(Any)"
   #nothing
 else
   pending
 end
end

Then /^Select keypair (.+) item from the keypair dropdown$/ do |keypair|
 if keypair == "(Any)"
   #nothing
 elsif keypair  == "(None)"
   #nothing
 else
   pending
 end
end

Then /^Select instance count (.+)$/ do |count|
 if count == "(Any)"
   #nothing
 else
   pending
 end
end

Then /^Select Security Group (.+) item from the security group checklist$/ do |security_group|
 if security_group == "(Any)"
   #nothing
 elsif security_group == "(None)"
   #nothing
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

Then /^[Tt]he instance should be resized$/ do
  old_flavor = @instance.flavor
  step %{
    * The instance #{ @instance.id } should not have flavor #{ old_flavor }
  }
end

Then /^[Tt]he instance will reboot$/ do
  steps %{
    * The instance #{ @instance.id } should be shown as rebooting
  }
end

Then /^[Tt]he instance will be Created$/ do
  step "The instances table should include the text #{ @instance_name }"
end

Then /^[Tt]he instance will be Not Created$/ do
  step "The instances table should not include the text #{ @instance_name }"
end


Then /^The (.+) form should not be visible$/ do |form_name|
  name = form_name.split.join('_').downcase
  unless @current_page.send("has_no_#{ name }_form?")
    raise "The #{ form_name } should not be visible, but it is."
  end
end

Then /^The (.+) table should include the text (.+)$/ do |table_name, text|
  unless @current_page.send("#{ table_name }_table").has_content?(text)
    raise "Couldn't find the text '#{ text }' in the #{ table_name } table."
  end
end

Then /^The (.+) table should not include the text (.+)$/ do |table_name, text|
  if @current_page.send("#{ table_name }_table").wait_for_content_to_disappear(text)
    raise "The text '#{ text }' should not be in the #{ table_name } table, but it is."
  end
end

Then /^The (.+) button should be disabled$/ do |button_name|
  button_name = button_name.split.join('_').downcase
  unless @current_page.send("has_#{ button_name }_button?")
    raise "Couldn't find '#{ button_name } button."
  end
end

Then /^The (.+) user row should be visible$/ do |username|
  user = IdentityService.session.users.find_by_name(username)
  unless user
    raise "Couldn't find a user named #{ username } in the system!"
  end

  unless @current_page.has_user_row?( user_id: user.id )
    raise "The row for user #{ username } should exist, but it doesn't."
  end
end

Then /^The instance (.+) should be shown as rebooting$/ do |instance_id|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    unless @current_page.instance_row( id: instance_id ).find('.task').has_content?('rebooting')
      raise "Instance #{ instance_id } is not shown as rebooting."
    end
  end
end

Then /^The instance (.+) should be shown as resuming$/ do |instance_id|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    unless @current_page.instance_row( id: instance_id ).find('.task').has_content?('resuming')
      raise "Instance #{ instance_id } is not shown as resuming."
    end
  end
end

Then /^The instance (.+) should not have flavor (.+)$/ do |instance_id, flavor_name|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    if @current_page.instance_row( id: instance_id ).find('.flavor').has_content?(flavor_name)
      raise "Expected flavor of instance #{ instance_id } to change. " +
            "Current flavor is #{ flavor_name }."
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

Then /^The (.+) message should be visible$/ do |span_name|
  span_name = span_name.split.join('_').downcase
  unless @current_page.send("has_#{ span_name }_span?")
    raise "The '#{ span_name.gsub('_',' ') }' message should be visible, but it's not."
  end
end

Then /^The (.+) message should not be visible$/ do |span_name|
  span_name = span_name.split.join('_').downcase
  if @current_page.send("has_#{ span_name }_span?")
    raise "The '#{ span_name.gsub('_',' ') }' message should not be visible, but it is."
  end
end

Then /^The (.+) user should be visible$/ do |user_name|
  unless @current_page.has_user_name_element?( name: user_name )
    raise "The user '#{ user_name }' should be visible, but it's not."
  end
end

Then /^The (.+) project should be visible$/ do |project_name|
  unless @current_page.has_project_name_element?( name: project_name )
    raise "The project '#{ project_name }' should be visible, but it's not."
  end
end

Then /^The (.+) project should not be visible$/ do |project_name|
  if @current_page.has_project_link?( name: project_name )
    raise "The project '#{ project_name }' should not be visible, but it is."
  end
end

Then /^The (.+) table should have (.+) rows$/ do |table_name, num_rows|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    table_name      = table_name.split.join('_').downcase
    table           = @current_page.send("#{ table_name }_table")
    actual_num_rows = table.has_content?('There are currently no') ? 0 : table.all('tbody tr').count
    num_rows        = num_rows.to_i

    if actual_num_rows != num_rows
      raise "Expected #{ num_rows } rows in the #{ table_name } table, but counted #{ actual_num_rows }."
    end
  end
end

Then /^The (.+) table's last row should include the text (.+)$/ do |table_name, text|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    table_name = table_name.split.join('_').downcase
    table_rows = @current_page.send("#{ table_name }_table").all('tbody tr')
    unless table_rows.last.has_content?(text)
      raise "Couldn't find the text '#{ text }' in the last row of the #{ table_name } table."
    end
  end
end

Then /^The user (.+) should not exist in the system$/ do |username|
  username = Unique.username(username)

  sleeping(1).seconds.between_tries.failing_after(20).tries do
    user = IdentityService.session.users.find_by_name(username)
    raise "User #{ username } should not exist, but it does." if user
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


Then /^Visit the (.+) page$/ do |page_name|
  page_class_name = "#{ page_name.downcase.capitalize }Page"
  unless Object.const_defined?( page_class_name )
    raise "The #{ page_name } page (#{ page_class_name }) is not defined " +
          "anywhere in the features/pages directory. You may have misspelled " +
          "the page's name, or you may need to define a #{ page_class_name } " +
          "class somewhere in that directory."
  end
  @current_page = eval(page_class_name).new
  @current_page.visit
end
