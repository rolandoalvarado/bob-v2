#=================
# GIVENs
#=================

Given /^I am not logged in$/ do
  @page = WebClientPage.new
  @page.click_log_out if @page.is_secure_page?
end

#=================
# WHENs
#=================

When /^I log in with the following credentials: (.*), (.*)$/ do |username, password|
  @page = LoginPage.new
  @page.visit
  @page.should_be_valid
  @page.fill_in :username, Unique.username(username)
  @page.fill_in :password, password
  @page.submit
end

When /^I log out$/ do
  @page.click_log_out
end

When /^I try to access the (.+) page$/ do |page_name|
  @page = eval("#{ page_name }Page").new
  @page.visit
end


#=================
# THENs
#=================