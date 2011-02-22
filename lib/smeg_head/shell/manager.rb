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
        setup_environment
        execute_command!
      rescue Error => e
        $stderr.puts e.message
        exit 1
      end

      def prepare_user
        @user_id = @arguments[0].presence
        raise Error, "Smeg Head was configured incorrectly for this user" unless user_id
        debug "Attempting User.find(#{user_id.to_i.inspect})"
        catching_not_found "Unable to find the user for your ssh key - Please check your account is configured correctly" do
          @user = User.find(user_id.to_i)
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

      def setup_environment
        current_context_env.each_pair do |k, v|
          ENV["SH_" + k.to_s.upcase] = v.to_s
        end
      end

      def execute_command!
        manager = repository.manager
        case command.verb
        when :read  then manager.upload_pack!
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

      def current_context_env
        {
          :repository_identifier    => repository.identifier,
          :original_repository_path => command.identifier,
          :current_user_id          => user.id,
          :permissions              => "TODO: Implement user permissions"
        }
      end

    end
  end
end