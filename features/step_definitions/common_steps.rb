#=================
# GIVENs
#=================

#=================
# WHENs
#=================

#=================
# THENs
#=================

Then /^I will be redirected to the (.+) page$/ do |page_name|
  @page = eval("#{ page_name }Page").new
  @page.should_be_current
end

Then /^the system will display (.+)$/ do |message|
  @page.should_have_content message
end