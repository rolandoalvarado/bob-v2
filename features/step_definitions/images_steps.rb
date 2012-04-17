#=================
# GIVENs
#=================

Given /^[Aa]n image is available for use$/ do
  image_service = ImageService.instance
  public_images = image_service.images.public
  raise "There are no available images at #{ ConfigFile.web_client_url }" if public_images.length == 0
  @image = public_images[0]
end

#=================
# WHENs
#=================


#=================
# THENs
#=================
