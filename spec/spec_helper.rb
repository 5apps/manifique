require "bundler/setup"
require "manifique"
require 'webmock/rspec'

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'support/*.rb')].each {|f| require f }
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.include ManifiqueFixtures

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
