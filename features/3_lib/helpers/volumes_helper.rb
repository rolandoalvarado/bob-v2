def test_volume_name
  Unique.volume_name('bob test')
end

def test_volume_snapshot_name
  Unique.string_with_whitespace('bob test')
end
