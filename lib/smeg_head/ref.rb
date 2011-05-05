module SmegHead
  # Implements a simple class responsible for maniliplating and dealing with refs.
  class Ref

    MAPPING = {
      :tags => :tag,
      :heads => :branch,
      :remotes => :remote,
      :notes   => :note
    }

    REVERSE_MAPPING = MAPPING.invert

    def self.part_to_name(part, default = nil)
      MAPPING[part.to_sym]
    end

    def self.name_to_part(part, default = nil)
      REVERSE_MAPPING[part.to_sym]
    end

    attr_reader :full, :parts, :type_key, :name

    def initialize(full_ref)
      @full  = full_ref
      @parts = full_ref.split("/", 3)
      @type_key  = @parts[1].to_sym
      @name  = @parts[2]
    end

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

    # Gets the current type of ref being modified.
    # @param [Symbol] the type of ref modified. :unknown for an unknown type of ref.
    def type
      @type ||= self.class.part_to_name(type_key, :unknown)
    end

  end
end