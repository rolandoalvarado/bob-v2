require_relative '../secure_page'

# The page that is displayed when clicking the images hyperlink
class ImagesPage < SecurePage

  path '/images'

  table    'images',                 '#images-list'
  button   'upload image',           '#upload-image'
  button   'disabled upload image',  '#upload-image.disabled'
  form     'upload image',           '#upload-image-modal'

  field    'image name',             '#name'
  dropdown 'image disk format',      '#disk-format'
  field    'image url',              '#image-url'
  field    'AKI url',                '#aki-url'
  field    'AMI url',                '#ami-url'
  field    'ARI url',                '#ari-url'
  dropdown 'project',                '#project'
  checkbox 'public',                 '#is-public'
  button   'confirm upload',         '#upload'

  table    'images',                 '#images-list'
  row      'image',                  xpath: "//table[@id='images-list']" +
                                            "//td[@class='name' and contains(text(), \"<name>\")]//.."
  cell     'image format',           xpath: "//table[@id='images-list']" +
                                            "//td[@class='name' and contains(text(), \"<name>\")]//.." +
                                            "//td[@class='container-format']"
  cell     'image status',           xpath: "//table[@id='images-list']" +
                                            "//td[@class='name' and contains(text(), \"<name>\")]//.." +
                                            "//td[@class='status']"

  button   'image menu',             "#image-<id> .dropdown-toggle"
  button   'edit image',             "#image-<id> .edit"
  button   'delete image',           "#image-<id> .destroy"
  button   'confirm image deletion', "a.okay"

end
