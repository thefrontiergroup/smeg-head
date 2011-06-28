# A simple wrapper script to make it easier to manage a authorized key file by adding
# and removing lines in a simplistic faction.
class AuthorizedKeysFile

  # Initializes a new authorized keys file at the given location.
  # @param [String] path the path to the authorized keys file
  def initialize(path)
    @path = File.expand_path(path.to_s)
  end

  # Adds a new key to the authorized keys file, saving the changes automatically.
  # @param [String] key the ssh key to add
  # @param [Hash<Symbol => [Boolean,String]>] options options for this key, auto converted.
  def add(key, options = {})
    with_file('a+') do |f|
      f.puts generate_key(key, options)
    end
    true
  end

  # Removes the given ssh key from the file in a clean manner. Will not remove it if non-match.
  # @param [String] key the ssh key to remove
  def remove(key)
    with_file do |f|
      lines = f.readlines
      key_matcher = /(\s|^)#{Regexp.escape(key)}(\s|$)/
      lines.reject! { |line| line =~ key_matcher }
      f.rewind
      f.write lines.join
      f.truncate f.pos
    end
    true
  end

  # Checks whether or not the current authorized keys file contains the specified key.
  # @param [String] key the ssh key to check for
  # @return [true, false] whether or not the given key is in the authorized keys file
  def has_key?(key)
    has_key = false
    with_file do |f|
      lines = f.readlines
      key_matcher = /(\s|^)#{Regexp.escape(key)}(\s|$)/
      has_key = lines.any? { |line| line =~ key_matcher }
    end
    has_key
  end

  protected

  def with_file(mode = 'r+')
    directory = File.dirname(@path)
    directory_existed = File.exist?(directory)
    file_existed      = File.exist?(@path)
    FileUtils.mkdir_p directory unless directory_existed
    File.open(@path, mode) do |file|
      file.flock File::LOCK_EX
      yield file if block_given?
    end
  ensure
    # Automatically takes care of setting the permissions of the dirs if they are created.
    File.chmod 0700, directory unless directory_existed
    File.chmod 0600, @path     unless file_existed
  end

  def generate_key(encoded_key, options)
    # no-port-forwarding,no-X11-forwarding,no-agent-forwarding
    normalised = []
    options.each_pair do |key, value|
      key = key.to_s.dasherize
      case value
      when true
        normalised << key
      when false
        normalised << "no-#{key}"
      else
        normalised << "#{key}=\"#{value}\""
      end
    end
    "#{normalised.join(',')} #{encoded_key}".strip
  end

end