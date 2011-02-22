require 'smeg_head/shell/command'

module SmegHead
  module Shell
    class Manager

      attr_reader :user_id, :user, :repository, :command

      def initialize(arguments)
        @arguments = arguments.first
      end

      def self.start(arguments = ARGV)
        new(arguments).start
      end

      def start
        prepare_user
        unpack_command
        prepare_repository
        execute_command!
      rescue Error => e
        $stderr.puts e.message
        exit 1
      end

      def prepare_user
        @user_id = @arguments[0].presence
        raise Error, "Smeg Head was configured incorrectly for this user" unless user_id
        debug "Attempting User.find(#{user_id.inspect})"
        catching_not_found "Unable to find the user for your ssh key - Please check your account is configured correctly" do
          @user = User.find(@user_name.to_i)
        end
      end

      def unpack_command
        debug "Checking the ssh command"
        original_command = ENV['SSH_ORIGINAL_COMMAND'].to_s.presence
        raise Error, "SSH invoked with out a command - try running it inside Git first" unless original_command
        @command = Command.parse(original_command)
      end

      def prepare_repository
        debug "Finding the repository from path = #{command.identifier}"
        @repository = Repository.from_path(command.identifier)
        raise Error, "Unknown git repository '#{command.identifier}'" unless @repository
      end

      def check_permission
        debug "Checking permissions"
      end

      def execute_command!
        manager = repository.manager
        case command.verb
        when :read  then manager.upload_path!
        when :write then manager.receive_pack!
        else raise Error, "Unknown repository verb of #{command.verb}"
        end
      end

      private

      def catching_not_found(description)
        yield if block_given?
      rescue ActiveRecord::RecordNotFound
        raise Error, description
      end

      def debug(message)
        $stderr.puts "[DEBUGGING] #{message}"
      end

    end
  end
end