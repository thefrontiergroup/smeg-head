require 'repository_manager'
class Repository < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  has_many :collaborations, :dependent => :destroy
  has_many :collaborators, :through => :collaborations, :source => :user

  validates :name, :owner, :presence => true
  validates :publically_accessible, :inclusion => {:in => [true, false]}

  is_sluggable :name

  before_save   :cache_clone_path
  before_create :identifier

  after_create  :create_repository
  after_destroy :cleanup_repository

  attr_accessible :name, :description, :publically_accessible, :default_branch

  scope :publically_accessible, where(:publically_accessible => true)

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

  # When a repository is created, will perform any tasks that need to
  # be taken care of before granting access.
  def create_repository
    manager.create!
  end

  # When a repository is destroyed, will perform any tasks that need to
  # be taken care of after the fact.
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
    writeable_by? user
  end

  def default_branch=(ref)
    manager.update_head(ref)
  end

  def default_branch
    manager.head
  end

  # Checks if the given user is present in the collaborators collection of this object.
  # @param [User] user the user to check
  # @return [true,false] whether or not the given user is a collaborator.
  def collaborator?(user)
    if collaborators.loaded?
      collaborators.include?(user)
    else
      collaborators.where(:id => user.id).exists?
    end
  end

  # Checks if the given user is a member for this repository.
  # @param [User] user the user to check
  # @return [true,false] whether or not the given user is a member.
  def member?(user)
    user == owner or collaborator?(user)
  end

  # Checks if the given user is an administrator for this repository.
  # @param [User] user the user to check
  # @return [true,false] whether or not the given user is an administrator.
  def administrator?(user)
    user == owner
  end

  # Checks if the given ssh public key or user can read this repository. Namely,
  # this involves a short cut check to see if the user is a valid person of
  # interest (that is, they have access to the current repository) or
  # the given key is a deploy key for this repository.
  # @param [SshPublicKey,User,Repository] target the target object to check permissions for.
  # @return [true, false] whether or not the specified key can read this repository.
  def readable_by?(target)
    case target
    when User         then target.ability.can? :show, self
    when SshPublicKey then readable_by? target.owner
    else false
    end
  end

  # Checks whether the given target object has write access to this repository.
  # Typically, this basically checks it is a user associated (versus a deploy key)
  # and that said user can
  def writeable_by?(target)
    case target
    when User         then member? target
    when SshPublicKey then writeable_by? target.owner
    else false
    end
  end

  # Converts the repository to a ssh url with a given default host.
  # @param [String] default_host the default host for the ssh server to be available at
  # @return [String] a formatted git clone url over ssh
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
