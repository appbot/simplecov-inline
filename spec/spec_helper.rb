require 'byebug'
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch
  minimum_coverage line: 100, branch: 100
end

require 'simplecov/inline'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_directory = @fixture_directory ||= File.join(File.dirname(__FILE__), 'fixtures')
