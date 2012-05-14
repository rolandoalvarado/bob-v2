# NOTE: These are steps that are to be used from within other step definitions
# only. DO NOT USE WITHIN FEATURE FILES. If you are using these steps directly
# in the feature files, then you are doing something very wrong. Please refer
# to http://www.relaxdiego.com/2012/04/using-cucumber.html for a better
# understanding on how to organize steps.

include Anticipate

Then /^Check the (\d+)(?:st|nd|rd|th) item in the (.+) checklist$/ do |item_number, list_name|
  list_name = list_name.split.join('_').downcase
  checkbox  = @current_page.send("#{ list_name }_checklist_items")[item_number.to_i - 1]
  checkbox.click unless checkbox.checked?
end

Then /^Choose the (\d+)(?:st|nd|rd|th) item in the (.+) radiolist$/ do |item_number, list_name|
  list_name = list_name.split.join('_').downcase
  @current_page.send("#{ list_name }_radiolist_items")[item_number.to_i - 1].click
end

Then /^Click the logout button if currently logged in$/ do
  @current_page ||= RootPage.new
  @current_page.visit                      # This removes any modal overlay
  unless @current_page.actual_url.empty?
    @current_page.logout_button.click if @current_page.has_no_login_form?
  end
end

Then /^Click the (.+) button$/ do |button_name|
  button_name = button_name.split.join('_').downcase
  @current_page.send("#{ button_name }_button").click
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

Then /^Connect to instance on (.+) via (.+)$/ do |ip_address, remote_client|
  begin
    case remote_client.upcase
    when 'RDP'
      %x{ rdesktop #{ ip_address } -u Administrator -p s3l3ct10n }
    when 'SSH'
      Net::SSH.start(ip_address, 'root', password: 's3l3ct10n') do |ssh|
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

Then /^Delete the (.+) user$/ do |user_name|
  user_name.strip!
  @current_page.user_menu_button( name: user_name ).click

  begin
    delete_user_link = @current_page.delete_user_link( name: user_name )
  rescue
    raise "Expected a link to delete the user '#{ user_name }' but none was found."
  end

  delete_user_link.click
  @current_page.delete_confirmation_button.click
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

Then /^Choose the (\d+)(?:st|nd|rd|th) item of the (.+) dropdown$/ do |item_number, dropdown_name|
  dropdown_name = dropdown_name.split.join('_').downcase
  @current_page.send("#{ dropdown_name }_dropdown_items")[item_number.to_i - 1].click
end

Then /^Choose (.+) in the (.+) dropdown$/ do |item_text, dropdown_name|
  if item = @current_page.send("#{ dropdown_name }_dropdown_items").find { |d| d.text == item_text }
    item.click
  else
    raise "Couldn't find the dropdown option '#{ item_text }'."
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

Then /^The instance (.+) should be shown as rebooting$/ do |instance_id|
  sleeping(1).seconds.between_tries.failing_after(5).tries do
    unless @current_page.instance_row( id: instance_id ).find('.task').has_content?('rebooting')
      raise "Instance #{ instance_id } is not shown as rebooting."
    end
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
