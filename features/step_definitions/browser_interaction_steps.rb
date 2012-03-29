# IMPORTANT: This is to be used in other step definition files only.
# DO NOT USE in feature files. If you do, you're writing very bad specs.

Given /^visit the (\S+) page$/ do |page_name|
  path = get_page_path(page_name)
  raise "Unknown page name '#{page_name}'. Make sure you spelled it correctly. Available pages are #{get_pages.keys.join(', ')}" if path.nil?
  visit path
end

Given /^fill in (\S+) with the (\S+) of (\S+)$/ do |field_id, attr_name, user_id|
  user = get_users[user_id]
  raise "The page at #{current_url} doesn't have a field with id = #{field_id}" unless page.has_selector?("\##{field_id}")
  raise "#{user} doesn't exist! Available users are #{get_users.keys.join(', ')}" unless user
  raise "#{user_id} doesn't have an attribute named #{attr_name}. Available attributes are #{user.keys.join(', ')}" unless user[attr_name]

  fill_in field_id, :with => user[attr_name]
end

Given /^click on (\S+)$/ do |field_id|
  raise "The page at #{current_url} doesn't have a field with id = #{field_id}" unless page.has_selector?("\##{field_id}")
  click_on field_id
end

Given /^current page should be the (\S+) page$/ do |page_name|
  path = get_page_path(page_name)
  raise "Unknown page name '#{page_name}'. Make sure you spelled it correctly. Available pages are #{get_pages.keys.join(', ')}" if path.nil?
  raise "You expected to be at the #{page_name} page but the server redirected you to #{get_page_name(current_path)} (#{current_path})" unless current_path == path
end