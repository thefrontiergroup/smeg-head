source 'http://rubygems.org'

gem 'rails', '~> 3.0.9'
gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'haml-rails'
gem 'formtastic', '~> 1.2'
gem 'uuid'
gem 'stringex'
gem 'slugged'
gem 'youthtree-settings'

gem 'devise'
gem 'ydd', :require => nil

gem 'dnssd'

gem 'angry_shell'
gem 'grit'
gem 'sshkey'

gem 'parslet'

gem 'inherited_resources'

gem 'navigasmic'
gem 'cancan'
gem 'nestive', :git => 'git://github.com/sj26/nestive.git', :require => ['nestive', 'nestive/railtie']

group :test, :development do
  gem 'rspec-rails'
  gem 'machinist',   '>= 2.0.0.beta2', :require => 'machinist/active_record'
  gem 'forgery',                       :require => 'forgery'
  gem 'guard', :require => nil
  gem 'guard-rspec', :require => nil
  gem 'guard-ego', :require => nil
  gem 'guard-bundler', :require => nil
  gem 'guard-cucumber', :require => nil
  gem 'guard-pow', :require => nil
  gem 'launchy', :require => nil
  gem 'debugger'
end

group :test do
  gem 'shoulda-matchers'
  gem 'rr'
  gem 'syntax', :require => nil
  gem 'fuubar'
  gem 'simplecov', :platforms => :ruby_19
  gem 'simplecov-rcov'
  gem 'rspec_junit_formatter'
  gem 'rspec_tag_matchers', git: 'https://github.com/sj26/rspec_tag_matchers'
  gem 'cucumber-rails', '~> 1.0.6'
  gem 'capybara', '~> 1.1.1'
  gem 'capybara-webkit'
  gem 'database_cleaner'

end

group :test_mac do
  #gem 'rb-fsevent', :require => false
  #gem 'growl', :require => false
end
