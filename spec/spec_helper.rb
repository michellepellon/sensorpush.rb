# frozen_string_literal: true

require 'sensorpush'
require 'webmock/rspec'

WebMock.disable_net_connect!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path
  File.expand_path('fixtures', __dir__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def json_fixture(file)
  JSON.parse(fixture(file))
end
