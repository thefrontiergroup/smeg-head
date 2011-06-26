class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  attr_accessible :user_name, :email, :password, :password_confirmation, :remember_me

  validates :user_name, :presence => true, :uniqueness => {:case_sensitive => false}
  validate  :validate_user_name_is_unchanged

  is_sluggable :user_name

  has_many :repositories, :as => :owner
  has_many :ssh_public_keys, :as => :owner

  has_many :group_memberships
  has_many :groups, :through => :group_memberships

  alias path_prefix to_param

  delegate :can?, :cannot?, :to => :ability

  def ability
    @ability ||= Ability.new(self)
  end

  protected

  def validate_user_name_is_unchanged
    errors.add :user_name, :can_not_be_changed if user_name_changed? and !new_record?
  end

end
