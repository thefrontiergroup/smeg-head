require 'ssh_public_key_manager'

class SshPublicKey < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  KEY_REGEXP = /\Assh\-(dss|rsa) [\=\+\/a-z0-9]+\Z/i

  validates   :owner, :name, :key, :fingerprint, :presence => true
  validates   :key, :format => {:with => KEY_REGEXP, :message => :does_not_look_like_a_key}
  validates   :name, :uniqueness => {:scope => [:owner_type, :owner_id]}
  validates   :key, :fingerprint, :uniqueness => true
  validate    :validate_ssh_key_format
  before_save :cache_key_fingerprint

  attr_accessible :name, :key

  # Takes in a supposed string containing an ssh key and performs transformation (in the form
  # of normalising it to a common format, minus comment) and fingerprinting as part of the setup
  # process.
  # @param [String] value the incoming ssh key value.
  def key=(value)
    value = value.to_s.strip.gsub("\n", '').gsub("\t", ' ').presence
    unless value.nil?
      # Strip off the comment
      value = value.split(' ', 3)[0, 2].join(' ')
    end
    write_attribute :key, value
    # Make sure we also set the fingerprint of the key.
    self.fingerprint = to_manager.fingerprint if value and value =~ KEY_REGEXP
  end

  # Returns the actual content / encoded key portion.
  # @return [String] the encoded key portion.
  def key_content
    key_parts[1]
  end

  # Returns a symbol denoting the algorithm in use by this public key.
  # @return [:dsa, :rsa, :unknown] the type of key in use.
  def algorithm
    case key_parts[0]
    when 'ssh-rsa' then :rsa
    when 'ssh-dss' then :dsa
    else                :unknown
    end
  end

  # Returns a SshPublicKeyManager setup for this object instance.
  # @return [SshPublicKeyManager] the preinitialized key manager.
  def to_manager
    SshPublicKeyManager.new self
  end

  protected

  def key_parts
    key.to_s.split(' ', 3)
  end

  def validate_ssh_key_format
    if key.present? and key =~ KEY_REGEXP
      # Use the SSH key manager to validate the key.
      if !to_manager.valid_contents?
        errors.add :key, :invalid_key_contents
      end
    end
  end

  def cache_key_fingerprint
    self.fingerprint ||= to_manager.fingerprint if key.present? && key =~ KEY_REGEXP
  end

end
