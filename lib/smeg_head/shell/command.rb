require 'shellwords'

module SmegHead
  module Shell
    # Provides a class to represent an incoming command and the action it represents.
    # This makes it possible to correctly parse and process incoming commands with the
    # basics of permission control.
    class Command

      VALID_COMMANDS = {
        :read  => "git-upload-pack",
        :write => "git-receive-pack"
      }
      COMMAND_TO_VERB = VALID_COMMANDS.invert

      attr_reader :command, :identifier, :raw, :parts

      # Initialises the current command from an incoming raw string.
      # This will normalise the incoming command to convert git- style
      # commands to make it easier to process.
      # @param [String] raw the raw command string from git-over-ssh.
      def initialize(raw)
        # We process the command so that it works with shellwords as expected.
        @raw        = raw.gsub(/^git /, 'git-')
        @parts      = Shellwords.shellwords(@raw.to_s)
        @command    = @parts[0].presence
        @identifier = @parts[1].presence
      end

      # Short hand to process parse a command and check the validity of it.
      # @param [String] cmd the incoming raw string of the current command
      # @return [Command] the parsed command after checking it's validity.
      def self.parse(cmd)
        new(cmd).tap(&:check!)
      end

      # Returns the current command representing this command
      # @return [:read, :write] the current verb
      def verb
        @verb ||= COMMAND_TO_VERB[command]
      end

      # Checks whether or not the current command is a read operation (e.g. a git pull).
      # @return [true, false] true iff it is a read operation
      def read?
        verb == :read
      end

      # Checks whether or not the current command represents a write operation (namely, are we processing a git push).
      # @return [true, false] true iff it is a write operation
      def write?
        verb == :write
      end

      # Checks the validity of the current command and it's verb mapping.
      def check!
        raise Error, "No command specified - Unable to process"                                  unless command
        raise Error, "Unknown git operation - Please contact the people running this repository" unless verb
        raise Error, "No git repository specified"                                               unless identifier
      end

    end
  end
end
