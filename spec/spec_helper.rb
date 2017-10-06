require 'bundler/setup'
require 'mistral_client'
require 'mistral_client/shared/deletable'
require 'mistral_client/shared/mistral_object'
require 'pry'
require 'vcr'

LOCAL_MISTRAL_URL =
  'http://127.0.0.1:8001/api/v1/namespaces/workflows/pods/mistral:8989/proxy/v2'.freeze

RSpec.configure do |config|
  # Turn deprecation warnings into errors.
  config.raise_errors_for_deprecations!

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.default_cassette_options = {
    record: :once, match_requests_on: %i[uri method body]
  }
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
