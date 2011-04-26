class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  attr_accessible :login, :email, :password, :password_confirmation, :remember_me

  validates :login, :presence => true

  is_sluggable :login

  has_many :repositories, :as => :owner

  has_many :group_memberships
  has_many :groups, :through => :group_memberships

  alias path_prefix to_param
end
