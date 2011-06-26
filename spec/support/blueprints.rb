require 'machinist/active_record'

Machinist.configure do |config|
  config.cache_objects = false
end

User.blueprint do
  email                 { Forgery(:internet).email_address }
  user_name             { Forgery(:internet).user_name }
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

require 'ssh_public_key_manager'
require 'tempfile'

def ExampleKeys.mock_authorized_keys!
  key_stack = Thread.current[:mock_authorized_keys_stack] ||= []
  test_keys_file = Tempfile.new('authorized_keys')
  test_keys_file.close
  key_stack << SshPublicKeyManager.authorized_keys_path
  SshPublicKeyManager.authorized_keys_path = test_keys_file.path
  p test_keys_file.path
end

def ExampleKeys.restore_authorized_keys!
  current_path = SshPublicKeyManager.authorized_keys_path
  key_stack = Thread.current[:mock_authorized_keys_stack] ||= []
  SshPublicKeyManager.authorized_keys_path = key_stack.pop
  File.delete(current_path) if File.exist?(current_path)
end

# Provides a method to temporary mock out the authorized keys file.
def ExampleKeys.with_mock_authorized_keys
  mock_authorized_keys!
  yield if block_given?
ensure
  restore_authorized_keys!
end