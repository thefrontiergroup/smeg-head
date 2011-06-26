require 'tempfile'
require 'authorized_keys'

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

end