require Rails.root.join('spec', 'support', 'blueprints')

# # Configure headless.
# require 'headless'
# AfterConfiguration do
#   headless = Headless.new :display => Process.pid
#   headless.start
#   at_exit { headless.destroy }
# end

# And Warden...
Warden.test_mode!
World Warden::Test::Helpers
After { Warden.test_reset! }

Capybara.javascript_driver = :webkit # Use capbara-webkit.

# Use a mocked out hub.
SmegHead.hub = SmegHead::MockHub.new
# And a mocked out authorized key file.
ExampleKeys.mock_authorized_keys!
at_exit { ExampleKeys.restore_authorized_keys! }