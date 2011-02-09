# Backtrace Settings
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }
# Rails.backtrace_cleaner.remove_silencers!

# Inflections
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Mime Types
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# Secret Token
SmegHead::Application.config.secret_token = Settings.rails.fetch(:secret, ActiveSupport::SecureRandom.hex(64))

# Session Configuration
SmegHead::Application.config.session_store :cookie_store, :key => Settings.rails.fetch(:session_name, '_smeg_head_session')

# Setup UUID.
UUID.state_file = Rails.root.join('tmp', 'uuid-state').to_s