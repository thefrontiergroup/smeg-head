require 'repository_manager'

class Repository < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  validates :name, :owner, :presence => true

  is_sluggable :name

  before_save   :cache_clone_path
  before_create :identifier

  after_create  :create_repository
  after_destroy :cleanup_repository

  # Normalises a path, expanding .. in the path and removing
  # a trailing .git suffix. Will also remove multiple slashes from
  # the path.
  def self.normalize_path(path)
    return if path.blank?
    # Remove .. and slashes where possible
    expanded = File.expand_path(path.to_s, '/')
    # Now remove the .git and the prefixed slash
    stripped = expanded.gsub(/\.git$/, '').gsub(/^\//, '')
    # If we still have a .. here, we know something is up
    return nil if stripped.include?('..')
    # Oh look, a name!
    stripped.presence
  end

  # Finds a repository from a given path, taking into account things like
  # the parent hierarchy. Returns nil when the given repository is not found.
  # @param [String] path the path to the repository
  # @return [nil,Repository] the repository (if found, otherwise nil)
  def self.from_path(path)
    normalized_path = normalize_path(path)
    return nil if normalized_path.blank?
    where(:clone_path => normalized_path).first
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
    return nil if owner.blank?
    File.join owner.path_prefix, to_param
  end

  # Returns the cached clone path, or a calculated clone path if not present
  # @return [String] the current clone path
  def clone_path
    self[:clone_path].presence || calculated_clone_path
  end

  def manager
    @manager ||= RepositoryManager.new(self)
  end

  def to_grit
    @to_grit ||= manager.to_grit
  end

  def create_repository
    manager.create!
  end

  def cleanup_repository
    manager.destroy!
  end

  # Returns a boolean denoting whether or not we should allow the given
  # user to modify the ref change passed in.
  # @param [User] user the user to check against
  # @param [SmegHead::RefChange] refchange the ref change to check.
  # @return [Boolean] true iff the user can perform the requested ref change.
  def allow_ref_change?(user, ref_change)
    # TODO: Implement ACL-based security checks here.
    return true
  end

  # General access check for the given user - Primarily, is the user able
  # to look at this repository? Finer-grained permissions are modifiable by the acl.
  # @param [User] user the user to check for
  # @return [Boolean] true iff the user can access the given repository.
  def accessible_by?(user)
    true
  end

  def to_ssh_url(default_host = 'localhost')
    user = Settings.smeg_head.fetch(:user, 'git')
    host = Settings.smeg_head.fetch(:host, default_host)
    "#{user}@#{host}:#{clone_path}.git"
  end

  protected

  # Sets the clone_path attribute to have a cached copy of the calculated clone path
  # so we can query on it.
  def cache_clone_path
    self[:clone_path] = calculated_clone_path
  end

end
