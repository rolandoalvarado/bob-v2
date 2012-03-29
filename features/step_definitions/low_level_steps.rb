# IMPORTANT: This is to be used in other step definition files only.
# DO NOT USE in feature files. If you do, you're writing very bad specs.

def get_pages
  return @pages if @pages

  @pages = {}
  @pages = {
    'Login' => '/',
    'Projects' => '/projects',
    'Users' => '/users',
    'Usage' => '/usage'
  }
end

def get_page_path(page_name)
  get_pages[page_name]
end

def get_page_name(path)
  get_pages.keys.each do |key|
    return key if get_pages[key] == path
  end

  return "(Unrecognized page)"
end

def select_nth_option(n, id)
  second_option_xpath = "//*[@id='#{id}']/option[#{n}]"
  second_option = find(:xpath, second_option_xpath).text
  select(second_option, :from => id)
end

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

Given /^The following user exists:$/ do |table|
  @user = table.hashes
  ensure_user_exists @user
end

Given /^The following users exist:$/ do |table|
  users_attrs = table.hashes
  users = get_users

  raise "Invalid users table. It must have 1 column labeled 'User'" unless users_attrs[0]['User']
  raise "Invalid User column value '#{user_attrs['User']}'. It shouldn't contain any whitespace" if users_attrs[0]['User'] =~ /\s/

  visit get_page_path('Login')

  message = "I couldn't log in to initialize the system with the users #{users_attrs.flatten.join(', ')}. "

  if page.has_selector?('#username')
    fill_in 'username', :with => get_config_file['cloud_admin_username']
  elsif page.has_selector?('#email')
    fill_in 'email', :with => get_config_file['cloud_admin_email']
  else
    message << "There was no place to input the admin username or email."
    raise message
  end

  fill_in 'password', :with => get_config_file['cloud_admin_password']

  if page.has_selector?('#login')
    click_on 'login'
  elsif page.has_selector?('#submit')
    click_on 'submit'
  else
    message << "I couldn't find any login button that had an id of 'submit' or 'login'"
    raise message
  end

  unless current_path == get_page_path('Projects')
    message << "I was expected to be logged in but the system redirected me to #{get_page_name(current_path)}"
    raise message
  end

  message = "I couldn't initialize the system with the users #{users_attrs.flatten.join(', ')}. "

  visit get_page_path('Users')

  unless current_path == get_page_path('Users')
    message << "I trying to get to the Users page but the system redirected me to #{get_page_name(current_path)}"
    raise message
  end

  if page.has_no_selector?('#adduser') &&
     page.has_no_button?('Add User') &&
     page.has_no_link?('Add User')
    message << "I couldn't find the button or link for adding a user"
    raise message
  end

  users_attrs.each do |user_attrs|
    user_id = user_attrs['User']

    next if users[user_id] &&
            users[user_id]['Username'] == user_attrs['Username'] &&
            users[user_id]['Password'] == user_attrs['Password'] &&
            users[user_id]['Name'] == user_attrs['Name'] &&
            users[user_id]['Email'] == user_attrs['Email']

    users[user_id] = {}

    ['Username', 'Password', 'Name'].each do |attribute|
      # Make the attributes available in capitalized and lower case form
      users[user_id][attribute] = user_attrs[attribute] || "#{user_id}#{attribute}"
      users[user_id][attribute.downcase] = users[user_id][attribute]
    end
    users[user_id]['Email'] = user_attrs['Email'] || "#{user_id}@mcloud_features.com"
    users[user_id]['email'] = users[user_id]['Email']

    users[user_id]['Role'] = user_attrs['Role'] || 'Developer'
    users[user_id]['role'] = users[user_id]['Role']

    next if page.has_content?("#{users[user_id]['email']}")

    click_on 'adduser' if page.has_selector?('#adduser')
    click_on 'Add User' if page.has_button?('Add User') || page.has_link?('Add User')

    message << "The New User form took too long to load."
    trying_every(1).seconds.failing_after(10).tries do
      raise message unless page.has_selector?('#name')
    end

    message = "I couldn't initialize the system with the users #{users_attrs.flatten.join(', ')}. "

    fill_in 'name', :with => users[user_id]['name']
    fill_in 'email', :with => users[user_id]['email']
    fill_in 'password', :with => users[user_id]['password']

    if page.has_selector?('#tenant-id')
      select_nth_option(2, 'tenant-id')
    elsif page.has_selector?('#projects')
      select_nth_option(2, 'projects')
    else
      message << "I couldn't find any drop-down field with id = 'projects'"
      raise message
    end

    if page.has_selector?('#create-project')
      click_on 'create-project'
    elsif page.has_link?('Save')
      click_on 'Save'
    else
      message << "I couldn't find any button or link with id = 'create-project'"
      raise message
    end

    message << "User #{user_id} couldn't be created!"
    trying_every(1).seconds.failing_after(10).tries do
      raise message if page.has_no_content?("#{users[user_id]['email']}")
    end
  end

  logout
end