class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  attr_accessible :email, :password, :password_confirmation, :remember_me
end
