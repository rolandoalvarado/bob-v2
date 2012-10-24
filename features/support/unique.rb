# This is a helper module that ensures certain values submitted to the server
# do not clash with values submitted by other instances of this suite. Consider
# this scenario:
#
#   Chris is running Bob from his machine. While Chris is halfway through the
#   process, Taut decides to also run Bob from his own machine. Since they're
#   both running Bob against the same mCloud environment, there's a high
#   possibility that Chris machine will delete an object that Taut's machine
#   is still using, resulting in an inaccurate error.
#
# To prevent the above scenario from happening, this module can add a random
# prefix or suffix or both to values provided to it. The prefix and suffix are
# pre-computed once and then saved to the config file as determined by
# Configuration::PATH (see config_file.rb), they will be permanent (unless
# deleted from the config file).
#
# Why are the random values computed at setup time?
# By computing the random values at setup-time, rather than at run-time, we avoid
# polluting the target mCloud environment with too many test objects. Since the
# prefix and suffix are fixed for each instance of mcloud_features, the suite
# can just re-use the objects each time it is executed.

module Unique
  def self.alpha
    ConfigFile.unique_alpha
  end

  def self.email(value)
    prefix = alpha[0, 4]
    "#{ prefix }_#{ value }"
  end

  def self.username(value = '', length = 16)
    "#{ value }#{ self.alpha }"[0, length - 1]
  end

  def self.user_name(value = '', length = 16)
    self.username(value, length)
  end

  def self.instance_name(value = '', length = 25)
    self.string_with_whitespace(value, length)
  end

  def self.security_group_name(value = '', length = 25)
    self.string_with_whitespace(value, length)
  end

  def self.name(value = '', length = 16)
    self.string_with_whitespace(value, length)
  end

  def self.project_name(value = '', length = 25)
    self.string_with_whitespace(value, length)
  end

  def self.string_with_whitespace(value = '', length = 16)
    "#{ value } #{ self.alpha }"[0, length - 1]
  end

  def self.string_without_whitespace(value = '', length = 16)
    "#{ value }_#{ self.alpha }"[0, length - 1]
  end

  def self.volume_name(value = '', length = 16)
    self.string_with_whitespace(value, length)
  end

  def self.instance_name(value = '', length = 16)
    self.string_with_whitespace(value, length)
  end

  def self.snapshot_name(value = '', length = 16)
    self.string_with_whitespace(value, length)
  end

  def self.image_name(value = '', length = 16)
    self.string_with_whitespace(value, length)
  end

  def self.keypair_name(value = '', length = 16)
    self.string_with_whitespace(value, length)
  end
end

