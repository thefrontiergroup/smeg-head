class Collaboration < ActiveRecord::Base

  belongs_to :repository
  belongs_to :user

  validates_presence_of :repository, :user
  validates_uniqueness_of :user_id, :scope => :repository_id
  validate :check_specified_user_name_details

  after_save :clear_specified_user_name

  # A virtual field used only for specifying the user name internally.
  attr_accessor :specified_user_name
  
  attr_accessible :user_id, :user_name
  
  def user_name=(value)
    user_name = value.to_s.strip.presence
    self.user = user_name && User.find_by_user_name(user_name)
    self.specified_user_name = user_name
  end
  
  def user_name
    specified_user_name || user.try(:user_name)
  end
  
  # To make it clear the specified_user_name field so that we don't get false positives.
  def user_id=(value)
    self.specified_user_name = nil
    super
  end
  
  def user_with_specified_user_name_reset=(value)
    self.specified_user_name = nil
    self.user_without_specified_user_name_reset = value
  end
  alias_method_chain :user=, :specified_user_name_reset
  
  # To make it clear the specified_user_name field so that we don't get false positives.
  def user_id_with_specified_user_name_reset=(value)
    self.specified_user_name = nil
    self.user_id_without_specified_user_name_reset = value
  end
  alias_method_chain :user_id=, :specified_user_name_reset
  
  protected
  
  def clear_specified_user_name
    self.specified_user_name = nil
  end
  
  def check_specified_user_name_details
    if specified_user_name.present? && user.blank?
      errors.add :user_name, :unable_to_find_user
    end
  end

end
