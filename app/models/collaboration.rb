class Collaboration < ActiveRecord::Base

  belongs_to :repository
  belongs_to :user

  validates_presence_of :repository, :user

end
