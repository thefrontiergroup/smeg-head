class SshKey < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  KEY_REGEXP = /\Assh\-(dsa|rsa) [\=\+\/a-z]\Z/i

  validates :owner, :name, :key, :presence => true
  validates :key,  :format => KEY_REGEXP

  # Need to validate the format of a ssh key


end
