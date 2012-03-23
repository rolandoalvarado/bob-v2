Then /^the system will display '(.+)'$/ do |message|
  page.should have_content(message)
end