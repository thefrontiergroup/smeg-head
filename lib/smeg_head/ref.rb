module SmegHead
  # Implements a simple class responsible for extracting symbolic information
  # out of a Git refstring for use when dealing with data.
  class Ref

    MAPPING = {
      :tags    => :tag,
      :heads   => :branch,
      :remotes => :remote,
      :notes   => :note
    }

    REVERSE_MAPPING = MAPPING.invert

    # Given a part value from the ref string, will return a symbolic
    # name describing what said ref contains.
    # @param [String, Symbol] part the ref part - e.g. 'remotes'
    # @param [Symbol] default the default value to return
    # @return [Symbol] the converted part name, e.g. :remote
    def self.part_to_name(part, default = nil)
      MAPPING.fetch part.to_sym, default
    end

    # Given a name value, returns the opposite ref part, allowing
    # reconstruction of a ref a symbolic name.
    # @param [String, Symbol] part the name of the part
    # @param [Symbol] default the default value to return
    # @return [Symbol] the part value for the given name, as a symbol
    def self.name_to_part(part, default = nil)
      REVERSE_MAPPING.fetch part.to_sym, default
    end

    attr_reader :full, :parts, :type_key, :name

    # Creates a new ref suitable for processing.
    # @param [String] full_ref the full ref string, e.g. "refs/remotes/other"
    def initialize(full_ref)
      @full     = full_ref
      @parts    = full_ref.split("/", 3)
      @type_key = @parts[1].to_sym
      @name     = @parts[2]
    end

    # Is the current ref a branch?
    # @return [true, false] true iff the current ref is a branch
    def branch?
      type == :branch
    end

    # Is the current ref a tag?
    # @return [true, false] true iff the current ref is a tag
    def tag?
      type == :tag
    end

    # Is the current ref a note?
    # @return [true, false] true iff the current ref is a note
    def note?
      type == :note
    end

    # Is the current ref a remote?
    # @return [true, false] true iff the current ref is a remote
    def remote?
      type == :remote
    end

    # Checks if the current ref has an unknown type
    def unknown?
      type == :unknown
    end

    # Gets the current type of ref.
    # @param [Symbol] the type of ref, :unknown for an unknown type of ref.
    def type
      @type ||= self.class.part_to_name(type_key, :unknown)
    end

    alias branch_name name
    alias tag_name    name
    alias remote_name name

  end
end
