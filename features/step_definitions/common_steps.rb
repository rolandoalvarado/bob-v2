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
  steps %{
    * page should have content '#{message}'
  }
end


