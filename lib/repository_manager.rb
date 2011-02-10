require 'angry_shell'
require 'fileutils'

# The Repository Manager class acts a base for performing operations on a given repository.
# This includes things such as manipulating and getting the state of the repository.
class RepositoryManager
  
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
    in_repository do
      # TODO: Add a way to hook into the results of creating the repository.
      # E.g. so we can have post-create hooks.
      cmd(:git, '--bare', :init).ok?
    end
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
    exec_in_repo! "git-receive-pack", path.to_s
  end
  
  # Starts upload-pack inside the repository.
  def upload_pack!
    exec_in_repo! "git-upload-pack", path.to_s
  end
  
  private
  
  # Shell Code taken from stuff I (Darcy) wrote for RVM
  
  # Takes an array / number of arguments and converts
  # them to a string useable for passing into a shell call.
  def escape_arguments(*args)
    return if args.blank?
    args.flatten.map { |a| escape_argument(a.to_s) }.join(" ")
  end

  # Given a string, converts to the escaped format. This ensures
  # that things such as variables aren't evaluated into strings
  # and everything else is setup as expected.
  def escape_argument(s)
    return "''" if s.empty?
    s.scan(/('+|[^']+)/).map do |section|
      section = section.first
      if section[0] == ?'
        "\\'" * section.length
      else
        "'#{section}'"
      end
    end.join
  end

  # From a command, will build up a runnable command. If args isn't provided,
  # it will escape arguments.
  def build_command(command, *args)
    "#{command} #{escape_arguments(args)}".strip
  end
  
  # Runs a command inside the git repository, using exec and git-shell to avoid 
  # the most common security attacks.
  def exec_in_repo!(*args)
    command = build_command('git-shell', '-c', *args)
    Dir.chdir path
    logger.info "Executing command in repo: \"#{command}\" in #{Dir.pwd}"
    exec *args
  end
  
  def cmd(*args, &blk)
    options = args.extract_options!
    command = build_command(*args)
    AngryShell::Shell.new(options.merge(:cmd => command), &blk)
  end
  
  def logger
    Rails.logger
  end
  
end