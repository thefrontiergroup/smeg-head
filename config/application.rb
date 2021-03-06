require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Load the SmegHead plugin early on so it is easy to hook into it.
require File.expand_path('../../lib/smeg_head/plugin', __FILE__)

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module SmegHead
  class Application < Rails::Application
    # config.plugins                                      = [ :exception_notification, :ssl_requirement, :all ]
    # config.active_record.observers                      = :cacher, :garbage_collector, :forum_observer
    # config.time_zone                                    = 'Central Time (US & Canada)'
    # config.i18n.load_path                              += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale                          = :de
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    config.encoding = "utf-8"
    config.filter_parameters += [:password]

    # Make sure we load smeg_head as early as possible.
    config.before_initialize { require 'smeg_head/all' }
    config.autoload_paths << "#{config.root}/app/concerns"

  end
end

# Avoid the SSHKey model trampling on our code...