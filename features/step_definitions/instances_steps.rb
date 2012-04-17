#=================
# GIVENs
#=================


#=================
# WHENs
#=================


#=================
# THENs
#=================

Then /^(?:[Hh]e|[Ss]he) ([Cc]an|[Cc]annot) [Cc]reate an instance in the project$/ do |can_or_cannot|
  can_create = can_or_cannot =~ /^[Cc]an$/

  page = LoginPage.new
  page.visit
  page.fill_in_username @user_attrs[:name]
  page.fill_in_password @user_attrs[:password]
  page.submit

  page = ShowProjectPage.new
  page.visit(@project.id)
  page.click_create_instance

  # choose a machine image
  # click submit
  # assert result

  pending # express the regexp above with the code you wish you had
end