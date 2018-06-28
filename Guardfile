guard :rspec, cmd: 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/manifique/(.+)\.rb$})     { |m| "spec/manifique/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
