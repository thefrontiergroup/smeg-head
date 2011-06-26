Devise.setup do |config|
  config.mailer_sender = "please-change-me@config-initializers-devise.com"

  require 'devise/orm/active_record'

  config.stretches                     = 10
  config.encryptor                     = :bcrypt
  config.pepper                        = Settings.devise.fetch(:pepper, ActiveSupport::SecureRandom.hex(64))
  config.authentication_keys           = [:email]
  # config.params_authenticatable      = true
  # config.http_authenticatable        = false
  # config.http_authenticatable_on_xhr = true
  # config.http_authentication_realm   = "Application"
  # config.confirm_within              = 2.days
  # config.remember_for                = 2.weeks
  # config.remember_across_browsers    = true
  # config.extend_remember_period      = false
  # config.password_length             = 6..20
  # config.email_regexp                = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  # config.timeout_in                  = 10.minutes
  # config.lock_strategy               = :failed_attempts
  # config.unlock_strategy             = :both
  # config.maximum_attempts            = 20
  # config.unlock_in                   = 1.hour
  # config.token_authentication_key    = :auth_token
  # config.scoped_views                = true
  # config.default_scope               = :user
  # config.sign_out_all_scopes         = false
  # config.navigational_formats        = [:html, :iphone]


  # config.warden do |manager|
  #   manager.oauth(:twitter) do |twitter|
  #     twitter.consumer_secret = <YOUR CONSUMER SECRET>
  #     twitter.consumer_key  = <YOUR CONSUMER KEY>
  #     twitter.options :site => 'http://twitter.com'
  #   end
  #   manager.default_strategies(:scope => :user).unshift :twitter_oauth
  # end
end
