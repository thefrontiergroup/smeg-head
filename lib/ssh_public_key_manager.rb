require 'tempfile'
require 'authorized_keys_file'

class SshPublicKeyManager
  include SmegHead::Commandable

  cattr_accessor :authorized_keys_path
  self.authorized_keys_path ||= "~#{Settings.smeg_head.fetch(:user, 'git')}/.ssh/authorized_keys"

  DEFAULT_OPTIONS = {:port_forwarding => false, :X11_forwarding => false, :agent_forwarding => false}

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
    authorized_keys_file.add raw_key, DEFAULT_OPTIONS.merge(shell_command_for_key)
  end

  def shell_command_for_key
    default_shell = "#{Rails.root.join('script', 'smeg-head-shell')} %s"
    current_shell = Settings.smeg_head.fetch(:shell_wrapper, default_shell)
    command_value = current_shell % key.id.to_s
    {:command => command_value}
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