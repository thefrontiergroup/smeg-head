require 'shellwords'

module SmegHead
  module Shell
    class Command

      VALID_COMMANDS = {
        :read  => /\Agit[ -]upload-pack\Z/,
        :write => /\Agit[ -]receive-pack\Z/
      }

      attr_reader :command, :identifier, :raw

      def initialize(raw)
        @raw        = raw
        @parts      = Shellwords.shellwords(raw.to_s)
        @command    = @parts[0].presence
        @identifier = @parts[1].presence
      end

      def self.parse(cmd)
        new(cmd).tap(&:process!)
      end

      def process!
        check_command!
      end

      def detected_verb
        VALID_COMMANDS.each_pair do |k, v|
          return k if v =~ command
        end
      end

      def verb
        @verb ||= detected_verb
      end

      def read?
        verb == :read
      end

      def write?
        verb == :write
      end

      def check_command!
        raise Error, "No command specified - Unable to process" unless command
        raise Error, "Unknown git operation - Please contact the people running this repository" unless verb
        raise Error, "No git repository specified" unless identifier
      end

    end
  end
end
