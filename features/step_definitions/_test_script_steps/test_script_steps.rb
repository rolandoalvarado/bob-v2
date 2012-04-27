# NOTE: These are steps that are to be used from within other step definitions
# only. DO NOT USE WITHIN FEATURE FILES. If you are using these steps directly
# in the feature files, then you are doing something very wrong. Please refer
# to http://www.relaxdiego.com/2012/04/using-cucumber.html for a better
# understanding on how to organize steps.

Then /^Click the logout button if currently logged in$/ do
  @current_page ||= WebClientPage.new
  @current_page.logout_button.click if @current_page.has_logout_button?
end

Then /^Click the (.+) button$/ do |button_name|
  @current_page.send("#{ button_name }_button").click
end

Then /^Current page should be the (.+) page$/ do |page_name|
  @current_page = eval("#{ page_name.downcase.capitalize }Page").new
  unless @current_page.has_expected_path?
    raise "Expected #{ @current_page.expected_path } but another page was returned: #{ @current_page.actual_path }"
  end
end

Then /^Current page should have the (.+) button$/ do |button_name|
  unless @current_page.send("has_#{ button_name }_button?")
    raise "Current page doesn't have a #{ button_name } button"
  end
end

Then /^Current page should have the (.+) field$/ do |field_name|
  unless @current_page.send("has_#{ field_name }_field?")
    raise "Current page doesn't have a #{ field_name } field"
  end
end

Then /^Current page should have the correct path$/ do
  unless @current_page.has_expected_path?
    raise "Expected #{ @current_page.expected_path } but another page was returned: #{ @current_page.actual_path }"
  end
end

Then /^Ensure that a project named (.+) exists$/ do |project_name|
  attributes = CloudObjectBuilder.attributes_for(:tenant, :name => project_name)
  @project = IdentityService.instance.ensure_project_exists( attributes )

  if @project.nil? or @project.id.empty?
    raise "Project couldn't be initialized!"
  end
end

Then /^Ensure that at least one image is available$/ do
  image_service = ImageService.instance
  public_images = image_service.get_public_images

  if public_images.empty?
    raise "There are no available images at #{ image_service.url }"
  else
    @image = public_images[0]
  end
end

Then /^Ensure that a user with username (.+) and password (.+) exists$/ do |username, password|
  username           = Unique.username(username)
  @user_attrs        = CloudObjectBuilder.attributes_for(:user, :name => username, :password => password)
  @user_attrs[:name] = Unique.username(@user_attrs[:name])

  @user = IdentityService.instance.ensure_user_exists(@user_attrs)
end

Then /^Fill in the (.+) field with (.+)$/ do |field_name, value|
  value = value.gsub(/^\([Nn]one\)$/, '')

  case field_name
  when 'username'
    value = Unique.username(value) unless value.empty?
  end

  @current_page.send("#{ field_name }_field").set value
end

# Then /^The system should display (.+)$/ do |the_content|
#   @current_page.should_have_content( the_content )
# end

Then /^Visit the (.+) page$/ do |page_name|
  @current_page = eval("#{ page_name.downcase.capitalize }Page").new
  @current_page.visit
end
