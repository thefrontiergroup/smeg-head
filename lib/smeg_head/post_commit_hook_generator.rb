module SmegHead
  class PostCommitHookGenerator

    NONEXISTANT_REF = "0000000000000000000000000000000000000000".freeze

    attr_reader :identifier, :repository, :old_ref, :new_ref, :full_ref_name, :manager

    def initialize(identifier, old_ref, new_ref, full_ref_name)
      @identifier    = identifier
      @repository    = Repository.find_by_identifier!(identifier)
      @manager       = @repository.manager
      @old_ref       = old_ref
      @new_ref       = new_ref
      @full_ref_name = full_ref_name
    end

    def ref_created?
      old_ref == NONEXISTANT_REF
    end

    def ref_deleted?
      new_ref == NONEXISTANT_REF
    end

    def ref_parts
      @ref_parts ||= full_ref_name.split("/", 3)
    end

    def ref_type
      case ref_parts[2]
      when "tags"    then :tag
      when "heads"   then :branch
      when "remotes" then :remote
      else :unknown
      end
    end

    def ref_name
      ref_name[2]
    end
    alias branch_name ref_name
    alias tag_name    ref_name

    def to_grit
      @grit ||= @manager.to_grit
    end

  end
end