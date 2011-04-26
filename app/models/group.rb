class Group < ActiveRecord::Base

  has_many :memberships, :class_name => "GroupMembership"
  has_many :users, :through => :memberships

  is_sluggable :name

end
