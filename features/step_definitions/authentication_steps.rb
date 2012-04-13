#=================
# GIVENs
#=================

#=================
# WHENs
#=================

When /^a user logs in with the following credentials: (.*), (.*)$/ do |username, password|
  @page = LoginPage.visit
  @page.fill_in :username, username
  @page.fill_in :password, password
  @page.submit
end

When /^an unauthenticated user tries to access the (.+) page$/ do |page_name|
  @page = eval("#{ page_name }Page").visit
end


#=================
# THENs
#=================