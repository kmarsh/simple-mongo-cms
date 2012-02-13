# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :off

group :specs do
  guard :rspec, :cli => '--color' do
    watch(%r{\.rb$}) { "spec" }
    watch(%r{^spec/.+_spec\.rb$})
  end
end
