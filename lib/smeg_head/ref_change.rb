module SmegHead
  # Represents a simple reference change in Git.
  # The format is relatively simple in that matches roughly what git
  # pushes to {pre,post}-receive hooks. In this case, we provide simple
  # helper methods to make it easier to operate on these changes.
  class RefChange
    extend ActiveSupport::Memoizable

    NONEXISTANT_REF = "0000000000000000000000000000000000000000".freeze

    attr_reader :old_ref, :new_ref, :full_ref_name

    def initialize(old_ref, new_ref, full_ref_name)
      @old_ref       = old_ref
      @new_ref       = new_ref
      @full_ref_name = full_ref_name
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

    # Explodes the full_ref_name out into the three parts:
    # * the ref prefix (simply `ref`)
    # * the type of ref (e.g. tags or heads)
    # * the actual identifier (e.g. `master`)
    # @return [Array<String>] the 3 parts of the ref
    def parts
      full_ref_name.split("/", 3)
    end
    memoize :parts

    # Gets the current type of ref being modified.
    # @param [Symbol] the type of ref modified. :unknown for an unknown type of ref.
    def type
      case ref_parts[2]
      when "tags"    then :tag
      when "heads"   then :branch
      when "remotes" then :remote
      when "notes"   then :note
      else :unknown
      end
    end
    memoize :type

    # Is the current change referencing a branch?
    def branch?
      type == :branch
    end

    # Is the current change referencing a tag?
    def tag?
      type == :tag
    end

    # Is the current change referencing a note?
    def note?
      type == :note
    end

    # Is the current change referencing a remote?
    def remote?
      type == :remote
    end

    # The name of the current change, minus the type declaration and ref prefix.
    def relative_name
      parts[2]
    end
    memoize :relative_name

    alias branch_name relative_name
    alias tag_name    relative_name

  end
end
