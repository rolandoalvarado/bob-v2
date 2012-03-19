# More info at https://github.com/guard/guard#readme

guard 'cucumber', :cli => '--profile default', :all_after_pass => false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})                      { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| (Dir[File.join("**/#{m[1]}.feature")][0] || 'features') }
  watch(%r{^features/support/cucumber/formatter/morph.+$}) { 'features' }
end