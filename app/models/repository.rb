class Repository < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  validates :name, :owner, :presence => true

  is_sluggable :name

  before_save :cache_clone_path

  # Normalises a path, expanding .. in the path and removing
  # a trailing .git suffix. Will also remove multiple slashes from
  # the path.
  def self.normalize_path(path)
    File.expand_path(path.to_s, '/').gsub(/\.git$/, '')[1..-1]
  end

  # Finds a repository from a given path, taking into account things like
  # the parent hierarchy. Returns nil when the given repository is not found.
  # @param [String] path the path to the repository
  # @return [nil,Repository] the repository (if found, otherwise nil)
  def self.from_path(path)
    normalized_path = normalize_path(path)
    return nil if normalize_path.blank?
    where(:clone_path => normalize_path).first
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

  # Calculates a new clone path for this repository, using the owners
  # path prefix in front of the current repositories slug.
  # @return [String] the composed clone path
  def calculated_clone_path
    File.join owner.path_prefix, to_param
  end

  # Returns the cached clone path, or a calculated clone path if not present
  # @return [String] the current clone path
  def clone_path
    self[:clone_path].presence || calculated_clone_path
  end

  protected

  # Sets the clone_path attribute to have a cached copy of the calculated clone path
  # so we can query on it.
  def cache_clone_path
    self[:clone_path] = calculated_clone_path
  end

end
