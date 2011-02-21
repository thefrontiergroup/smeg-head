source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'haml-rails'
gem 'formtastic', '~> 1.2'
gem 'uuid'
gem 'stringex'
gem 'slugged'
gem 'youthtree-settings'

gem 'devise'
gem 'ydd', :require => nil

gem 'angry_shell'
gem 'grit'

group :test, :development do
  gem 'rspec',       '~> 2.1'
  gem 'rspec-rails', '~> 2.1'
  gem 'machinist',   '>= 2.0.0.beta2', :require => 'machinist/active_record'
  gem 'forgery',                       :require => 'forgery'
  # Guard basics
  gem 'guard', :require => nil
  gem 'guard-rspec', :require => nil
  if RUBY_VERSION < '1.9'
    gem 'ruby-debug'
  else
    gem 'ruby-debug19'
  end
end

group :test do
  gem 'remarkable',              '>= 4.0.0.alpha4', :require => 'remarkable/core'
  gem 'remarkable_activerecord', '>= 4.0.0.alpha4', :require => 'remarkable/active_record'
  gem 'rr'
  gem 'rcov', :require => nil
  gem 'syntax', :require => nil
  gem 'fuubar'
  gem 'simplecov' unless RUBY_VERSION < '1.9'
end

group :test_mac do
  gem 'rb-fsevent', :require => false
  gem 'growl', :require => false
end