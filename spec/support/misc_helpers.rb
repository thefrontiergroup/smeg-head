module MiscHelpers

  def subject_class
    self.class.describes || self.class.description
  end

  def with_hub(hub, &blk)
    begin
      old_hub, SmegHead.hub = SmegHead.hub, hub
      yield if block_given?
    ensure
      SmegHead.hub = old_hub
    end
  end

end