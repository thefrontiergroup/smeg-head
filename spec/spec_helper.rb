if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'cancan/matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Use a mocked out hub.
SmegHead.hub = SmegHead::MockHub.new
# And a mocked out authorized key file.
ExampleKeys.mock_authorized_keys!
at_exit { ExampleKeys.restore_authorized_keys! }

RSpec.configure do |config|
  config.mock_with :rr
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, :type => :controller
  config.include MiscHelpers
  config.before(:each) { Machinist.reset_before_test }

  config.after(:each) do
    FileUtils.rm_rf(RepositoryManager.base_path) if defined?(RepositoryManager)
  end

end