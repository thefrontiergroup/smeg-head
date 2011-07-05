# The Repository Manager class acts a base for performing operations on a given repository.
# This includes things such as manipulating and getting the state of the repository.
class RepositoryManager
  include SmegHead::Commandable

  class Error                 < StandardError; end
  class NonexistantRepository < Error; end

  attr_reader :repository

  def self.base_path
    Rails.root.join("repositories", Rails.env)
  end

  # Initializes a new repository manager with the given repository.
  def initialize(repository)
    @repository = repository
  end

  # Returns the directory name for this git repository.
  # @return [String] the directory name for this repository
  def directory_name
    @directory_name ||= "#{repository.identifier}.git"
  end

  # Gets a pathname object for the path to this repository.
  # @return [Pathname] the path to the current repository
  def path
    @path ||= self.class.base_path.join(directory_name)
  end

  # When it doesn't exist, creates (and initializes) a git bare repository.
  def create!
    return if path.exist?
    FileUtils.mkdir_p path
    result = in_repository { cmd(:git, '--bare', :init).ok? }
    setup_hooks! if result
    result
  end

  # Automatically symlinks the hooks into place for the current
  # repository, taking care to make sure it matches the correct object.
  def setup_hooks!
    shared_path      = Rails.root.join("hooks")
    destination_path = path.join('hooks')
    FileUtils.mkdir_p destination_path
    Dir[shared_path.join('**', '*')].each do |original_hook|
      hook_name = File.basename(original_hook)
      hook_path = destination_path.join(hook_name)
      FileUtils.rm_rf hook_path
      FileUtils.ln_s original_hook, hook_path
    end
    true
  end

  # Updates the branch that head points to, effectively letting the user change
  # the default branch when users change repos.
  # @param [String] ref the branch name to update the master
  # @return [Boolean] whether the change was successful
  def update_head(ref)
    return if ref.blank?
    ref = ref.to_s
    return unless branches.include?(ref)
    full_ref = "refs/heads/#{ref}"
    in_repository { cmd(:git, 'symbolic-ref', '-q', 'HEAD', full_ref).ok? }
  end
  alias head= update_head

  # Gets the current head for the repository.
  def head
    Grit::Head.current(to_grit).try :name
  end

  def destroy!
    FileUtils.rm_rf(path) if path.exist?
  end

  # Yields a block whilst in a given directory.
  # Used for situations where we want to run git commands.
  def in_repository
    Dir.chdir(path) { yield if block_given? }
  end

  def to_grit
    raise NonexistantRepository.new("The given repository does not exist") unless path.exist?
    Grit::Repo.new path
  end

  # Starts receive-pack in the repository.
  def receive_pack!
    run_in_repo! "git-receive-pack", path.to_s
  end

  # Starts upload-pack inside the repository.
  def upload_pack!
    run_in_repo! "git-upload-pack", path.to_s
  end

  def branches
    Grit::Head.find_all(to_grit).map(&:name)
  end

  private

  # Runs a command inside the git repository, using exec and git-shell to avoid
  # the most common security attacks.
  def run_in_repo!(*args)
    command = build_command(*args)
    rubyopt, ENV['RUBYOPT'] = ENV['RUBYOPT'], nil
    Dir.chdir path do
      logger.info "Executing command in repo: \"#{command}\" in #{Dir.pwd}"
      system Settings.commands.fetch(:git_shell, 'git-shell'), '-c', command
    end
  ensure
    ENV['RUBYOPT'] = rubyopt # Filter out the environment.
  end

end
