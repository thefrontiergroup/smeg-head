module MiscHelpers
  
  def subject_class
    self.class.describes || self.class.description
  end
  
end