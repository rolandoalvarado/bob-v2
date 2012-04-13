#=================
# GIVENs
#=================

#=================
# WHENs
#=================

#=================
# THENs
#=================

Then /^(?:[Hh]e|[Ss]he) will be redirected to the (.+) page$/ do |page_name|
  eval("#{ page_name }Page").new.should_be_current
end

Then /^the system will display '(.+)'$/ do |message|
  @page.should_have_content message
end