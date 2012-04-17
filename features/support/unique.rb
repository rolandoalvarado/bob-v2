# This is a helper module that ensures certain values submitted to the server
# do not clash with values submitted by other instances of this suite. Consider
# this scenario:
#
#   Chris is running the mcloud_features suite from his machine. While Chris is
#   halfway through the process, Taut decides to run the suite from his own
#   machine. Since they're both running their mcloud_features suite against the
#   same mCloud environment, there's a high possibility that Chris machine will
#   delete an object that Taut's machine is still using, resulting in an
#   inaccurate error.
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
  def self.username(value)
    "#{ value }_#{ ConfigFile.unique_alpha }"[0, 15]
  end

  def self.alpha
    ConfigFile.unique_alpha
  end
end