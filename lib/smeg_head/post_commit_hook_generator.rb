module SmegHead
  class PostCommitHookGenerator

    attr_reader :identifier, :repository, :old_ref, :new_ref, :full_ref_name, :manager

    def initialize(identifier)
      @identifier    = identifier
      @repository    = Repository.find_by_identifier!(identifier)
      @manager       = @repository.manager
    end

    def to_grit
      @grit ||= @manager.to_grit
    end

  end
end