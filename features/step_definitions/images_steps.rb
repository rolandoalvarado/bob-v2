#=================
# GIVENs
#=================

Given /^[Aa]n image is available for use$/ do
  steps %{
    * Ensure that at least one image is available
  }
end

Given /^The project does not have any running instances$/ do
  pending # express the regexp above with the code you wish you had
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
