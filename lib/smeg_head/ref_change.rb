require 'smeg_head/ref'

module SmegHead
  # Represents a simple reference change in Git.
  # The format is relatively simple in that matches roughly what git
  # pushes to {pre,post}-receive hooks. In this case, we provide simple
  # helper methods to make it easier to operate on these changes.
  class RefChange

    NONEXISTANT_REF = "0000000000000000000000000000000000000000".freeze

    attr_reader :old_ref, :new_ref, :full_ref_name, :ref

    def initialize(old_ref, new_ref, full_ref_name)
      @old_ref       = old_ref
      @new_ref       = new_ref
      @full_ref_name = full_ref_name
      @ref           = SmegHead::Ref.new(full_ref_name)
    end

    # Does the given ref represent something being created?
    def created?
      old_ref.nil? or old_ref == NONEXISTANT_REF
    end

    # Does the given ref represent something being deleted?
    def deleted?
      new_ref.nil? or new_ref == NONEXISTANT_REF
    end

    # Is the ref a simple change of the given reference?
    def changed?
      not (created? or deleted?)
    end

  end
end
