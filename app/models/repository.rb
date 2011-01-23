class Repository < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  validates :name, :owner, :presence => true

  # Finds a repository from a given path, taking into account things like
  # the parent hierarchy. Returns nil when the given repository is not found.
  # @param [String] path the path to the repository
  # @return [nil,Repository] the repository (if found, otherwise nil)
  def self.from_path(path)
  end

  # Prevents assignment of identifier directly to avoid people changing their repository uuid.
  # @param [String, nil] identifier What the identifier should be set to / the ignored value.
  def identifier=(value)
  end

  # Returns the identifier for this repository, initialising it to a UUID
  # when it has yet to be set.
  # @return [String] the identifier for this repository.
  def identifier
    identifier = self[:identifier]
    if identifier.blank?
      identifier = self[:identifier] = UUID.generate
    end
    identifier
  end

end
