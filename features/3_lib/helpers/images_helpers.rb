def test_image_name
  Unique.image_name('bob')
end

def test_image_url(format)
  case format.downcase
  when 'aki'
    'http://cloud-image.morphexchange.org/ubuntu/12.04/precise-kernel-3.2.0-rc1.0.0'
  when 'ari'
    'http://cloud-image.morphexchange.org/ubuntu/12.04/initrd.img-3.2.0-23-rc1.0.0'
  when 'ami'
    'http://cloud-image.morphexchange.org/ubuntu/12.04/Ubuntu-12.04-x86_64-b1.0.1.img'
  end
end
