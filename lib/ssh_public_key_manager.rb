require 'tempfile'
require 'authorized_keys_file'

class SshPublicKeyManager
  include SmegHead::Commandable

  cattr_accessor :authorized_keys_path
  self.authorized_keys_path ||= '~/.ssh/authorized_keys'

  attr_reader :key

  def initialize(key)
    @key = key
  end

  def valid_contents?
    SSHKey.valid? raw_key
  end

  def fingerprint
    unpacked = key.key_content.to_s.unpack('m*').first
    Digest::MD5.hexdigest(unpacked).gsub(/(.{2})(?=.)/, '\1:\2')
  end

  def raw_key
    key.key
  end

  # Adds this key to the authorized keys file
  def add
    authorized_keys_file.add raw_key
  end

  # Removes this key from the authorized keys file
  def remove(old_key = false)
    key_to_remove = old_key ? key.key_was : raw_key
    authorized_keys_file.remove key_to_remove
  end

  def self.authorized_keys_file
    AuthorizedKeysFile.new authorized_keys_path
  end

  delegate :authorized_keys_file, :to => 'self.class'

end