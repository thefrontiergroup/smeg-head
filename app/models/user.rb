class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  attr_accessible :login, :email, :password, :password_confirmation, :remember_me

  validates :login, :presence => true

  is_sluggable :login

end
