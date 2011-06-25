require 'machinist/active_record'

Machinist.configure do |config|
  config.cache_objects = false
end

User.blueprint do
  email                 { Forgery(:internet).email_address }
  login                 { Forgery(:internet).user_name }
  password              { Forgery(:basic).password }
  password_confirmation { object.password }
end

Repository.blueprint do
  name  { Forgery(:name).job_title }
  owner { User.make }
end

SshPublicKey.blueprint do
  name  { Forgery(:name).job_title }
  key   { ExampleKeys.generate  }
  owner { User.make }
end

require 'ostruct'
example_keys = {}
%w(bad_rsa bad_dsa good_dsa good_rsa good_rsa_4096).each do |file|
  example_keys[file] = File.read(Rails.root.join('spec/support/example_keys', "#{file}.pub"))
end
ExampleKeys = OpenStruct.new(example_keys)
ExampleKeys.known_good_keys = [ExampleKeys.good_dsa, ExampleKeys.good_rsa, ExampleKeys.good_rsa_4096]
ExampleKeys.known_bad_keys  = [ExampleKeys.bad_dsa, ExampleKeys.bad_rsa]

def ExampleKeys.generate(type = 'rsa', size = 1024)
  SSHKey.generate(:type => type, :size => size).ssh_public_key
end