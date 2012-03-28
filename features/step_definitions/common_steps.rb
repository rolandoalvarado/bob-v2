#=================
# GIVENs
#=================


#=================
# WHENs
#=================


#=================
# THENs
#=================

Then /^the system will display '(.+)'$/ do |message|
  page.should have_content(message)
end

Then /^(.+) should receive the following email notification:$/ do |username, message|
  pending
end

Then /^the new user will be created$/ do
  steps %{
    visit Users page
    page should contain Jheff
  }
end

Then /^the new user will not be created$/ do
  steps %{
    visit Users page
    page should not contain Jheff
  }
end
