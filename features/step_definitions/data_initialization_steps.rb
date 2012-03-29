Given /^The following user exists:$/ do |table|
  @user = table.hashes
  ensure_user_exists @user
end

Given /^The following users exist:$/ do |table|
  users_attrs = table.hashes
  users = get_users

  raise "Invalid users table. It must have 1 column labeled 'User'" unless users_attrs[0]['User']
  raise "Invalid User column value '#{user_attrs['User']}'. It shouldn't contain any whitespace" if users_attrs[0]['User'] =~ /\s/

  logout if logged_in?
  login_as_admin

  users_attrs.each do |user_attrs|
    user_id = user_attrs['User']

    next if users[user_id] &&
            users[user_id]['Username'] == user_attrs['Username'] &&
            users[user_id]['Password'] == user_attrs['Password'] &&
            users[user_id]['Name'] == user_attrs['Name'] &&
            users[user_id]['Email'] == user_attrs['Email']

    users[user_id] = {}

    ['Password', 'Name'].each do |attribute|
      # Make the attributes available in capitalized and lower case form
      users[user_id][attribute] = user_attrs[attribute] || "#{user_id}#{attribute}"
      users[user_id][attribute.downcase] = users[user_id][attribute]
    end

    users[user_id]['email'] = users[user_id]['Email'] = user_attrs['Email'] || "#{user_id}@mcloud_features.com"
    users[user_id]['role']  = users[user_id]['Role']  = user_attrs['Role'] || 'Developer'

    next if page.has_content?("#{users[user_id]['email']}")

    unless page.has_selector?('#add-user')
      message << "I couldn't find a link or button with id = 'add-user'"
      raise message
    end
    click_on 'adduser'

    trying_every(1).seconds.failing_after(10).tries do
      raise "#{message}The New User form took too long to load." unless page.has_selector?('#name')
    end

    fill_in 'name', :with => users[user_id]['name']
    fill_in 'email', :with => users[user_id]['email']
    fill_in 'password', :with => users[user_id]['password']

    unless page.has_selector?('#projects')
      message << "I couldn't find any drop-down field with id = 'projects'"
      raise message
    end

    select_nth_option(2, 'projects')

    unless page.has_selector?('#create-project')
      message << "I couldn't find any button or link with id = 'create-project'"
      raise message
    end

    click_on 'create-project'

    message << "User #{user_id} couldn't be created!"
    trying_every(1).seconds.failing_after(10).tries do
      raise message if page.has_no_content?("#{users[user_id]['email']}")
    end
  end

  logout
end