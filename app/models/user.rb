class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  attr_accessible :login, :email, :password, :password_confirmation, :remember_me

  validates :login, :presence => true, :uniqueness => true
  validate  :validate_login_is_unchanged

  is_sluggable :login

  has_many :repositories, :as => :owner
  has_many :ssh_public_keys, :as => :owner

  has_many :group_memberships
  has_many :groups, :through => :group_memberships

  alias path_prefix to_param

  protected

  def validate_login_is_unchanged
    errors.add :login, :can_not_be_changed if login_changed? and !new_record?
  end

end
