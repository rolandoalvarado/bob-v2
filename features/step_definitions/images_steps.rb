#=================
# GIVENs
#=================

Given /^[Aa]n image is available for use$/ do
  image_service = ImageService.instance
  public_images = image_service.images.public
  raise "There are no available images at #{ ConfigFile.web_client_url }" if public_images.length == 0
  @image = public_images[0]
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
