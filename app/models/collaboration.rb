class Collaboration < ActiveRecord::Base

  belongs_to :repository
  belongs_to :user

  validates_presence_of :repository, :user
  validates_uniqueness_of :user_id, :scope => :repository_id
  
  attr_accessible :user_id, :user_name
  
  def user_name=(value)
    self.user = value.presence && User.find_by_user_name(value.to_s)
  end
  
  def user_name
    user.try :user_name
  end

end
