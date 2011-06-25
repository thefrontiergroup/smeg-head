require Rails.root.join('spec', 'support', 'blueprints')

# Configure headless.
require 'headless'
AfterConfiguration do
  headless = Headless.new :display => Process.pid
  headless.start
  at_exit { headless.destroy }
end

# And Warden...
Warden.test_mode!
World Warden::Test::Helpers
After { Warden.test_reset! }

Capybara.javascript_driver = :webkit # Use capbara-webkit.