# IMPORTANT: The implementation of these methods
# will change over time as we find a more efficient
# way of ensuring these conditions. Therefore, please
# use them only in GIVEN step definitions.

def ensure_project_exists(name = "test project by mcloud_features", description = "test project by mcloud_features")
  login_as_admin unless logged_in?
  visit '/projects'
  return if page.has_content?(name)

  click_on 'Create Project'
  fill_in 'editable_project_name', :with => name
  fill_in 'editable_description', :with => description
  click_on 'save_cloud_button'

  unless page.has_content?(name) && page.has_content?(description)
    raise_init_error "Couldn't ensure project '#{name}' exists for testing"
  end
  logout
end

def ensure_user_exists(info)
  login_as_admin unless logged_in?
  visit '/users'
  return if page.has_content?("#{info['Username']}") &&
            page.has_content?("#{info['Email']}")

  click_on 'Add User'
  fill_in 'name', :with => info['Username']
  fill_in 'email', :with => info['Email']
  fill_in 'password', :with => info['Password']
  select info['Project'], :from => 'tenant-id'
  click_on 'Save'

  unless page.has_content?("#{info['Username']}") &&
         page.has_content?("#{info['Email']}")
    raise_init_error "Couldn't ensure user '#{info['Username']}' exists for testing"
  end
  logout
end

def login_as_admin
  config = get_config_file
  error_message = ""

  begin
    visit('/')
    fill_in 'email', :with => config['cloud_admin_email']
    fill_in 'password', :with => config['cloud_admin_password']
    click_button 'submit'
  rescue Exception => e
    error_message = e.to_s.gsub(/cannot fill in, no text field, text area or password field with id, name, or label 'email' found/,"The login page doesn't have a field with id = 'email'")
  end

  unless logged_in?
    raise_init_error "I couldn't log in as admin with email '#{config['cloud_admin_email']}' and password '#{config['cloud_admin_password']}'. I need to do this to set up some objects prior to doing the actual tests. Please make sure that this admin user exists in the system before proceeding. NOTE: Make sure this user has cloud admin rights to the DCU.\n\n#{error_message}"
  end
end

def raise_init_error(message)
  raise "Initialization Error: #{message}"
end