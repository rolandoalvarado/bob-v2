Then /^the system will display '(.+)'$/ do |message|
  page.should have_content(message)
end

Then /^(.+) should receive the following email notification:$/ do |username, message|
  pending
end