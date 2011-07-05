require 'smeg_head/shell/command'

require 'drb/drb'
require 'drb/unix'

module SmegHead
  module Shell
    class Manager

      attr_reader :user, :repository, :command, :ssh_key, :owner

      def initialize(arguments)
        @arguments = arguments
      end

      def self.start(arguments = ARGV)
        new(arguments).start
      end

      # The main entry point for the program - Will perform all of the setup
      # required and correctly show any error messages encountered.
      def start
        prepare_ssh_public_key
        prepare_owner
        unpack_command
        prepare_repository
        check_permission
        setup_environment
        with_drb_server(self) { execute_command! }
      rescue Error => e
        $stderr.puts e.message
        exit 1
      end

      # Load the current ssh key, depending on the type of key found
      # we will then load the child data.
      def prepare_ssh_public_key
        key_id = @arguments[0].presence
        raise Error, 'No SSH Public Key was specified' unless key_id.present?
        debug "Loading the current SSH Public Key"
        catching_not_found "Unknown SSH Key - Something has gone wrong deep inside Smeg Head - Please remove and readd the key." do
          @ssh_key = SshPublicKey.find(key_id.to_i)
        end
      end

      def prepare_owner
        @owner = ssh_key.owner
        case owner
        when User then prepare_user
        end
      end

      # Lookup the current user, raising an exception when we don't know who said user is.
      def prepare_user
        @user = @owner
      end

      # Checks for a valid command from the SSH_ORIGINAL_COMMAND environment variable.
      # As part of this, it will setup @command to point to a SmegHead::Shell::Command
      # instance.
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

      # Checks the current user has _any_ permissions on the repository. Actual ACL-based permission checks
      # are performed after this point as part of the pre-receive hook.
      def check_permission
        debug "Checking permissions"
        case command.verb
        when :read
          raise Error, "I'm sorry Dave, I can't let you read this repository." unless repository.readable_by?(ssh_key)
        when :write
          raise Error, "I'm sorry Dave, I can't let you write to this repository." unless repository.writeable_by?(ssh_key)
        end
      end

      # Pass through any environment variables we need to the child process to process what is going on.
      def setup_environment
        debug "Setting up enviroment"
        current_context_env.each_pair do |k, v|
          ENV["SH_" + k.to_s.upcase] = v.to_s
        end
      end

      # Automatically runs the correct command under a given repository by
      # using the current
      def execute_command!
        debug "Running #{command.verb} under #{manager.path}"
        case command.verb
        when :read  then manager.upload_pack!
        when :write then manager.receive_pack!
        end
      end

      # Useful operations on the other side

      # Returns a boolean denoting whether or not an action can be processed.
      # @param [String] old_ref the old ref to check, or all zeros if nothing.
      # @param [String] new_ref the new ref to check, or all zeros if nothing.
      # @param [String] full_ref the full name of the ref being modified, e.g. refs/branches/master
      def can_process_ref?(old_ref, new_ref, full_ref)
        change = SmegHead::RefChange.new(old_ref, new_ref, full_ref)
        repository.allow_ref_change? user, change
      end

      # Process a series of refs after the fact.
      def notify_refs!(ref_collection)
        debug "Notifying for ref collection: #{ref_collection.inspect}"
        payload = current_context_env.merge(:refs => ref_collection)
        # Do something with the payload. Most likely, insert it into the resque processor.
        nil # Return nil so we don't transmit anything back over DRb.
      end

      private

      # Extract the manager out into a special method to make it easier to mock out.
      def manager
        @_manager ||= repository.try(:manager)
      end

      def with_drb_server(ctx)
        server = DRb::DRbServer.new 'drbunix:', ctx
        ENV['SH_DRB_SERVER'] = server.uri
        yield if block_given?
      ensure
        ENV['SH_DRB_SERVER'] = nil
        server.stop_service
      end

      def catching_not_found(description)
        yield if block_given?
      rescue ActiveRecord::RecordNotFound
        raise Error, description
      end

      def debug(message)
        $stderr.puts "[DEBUGGING] #{message}" if Rails.env.development?
      end

      def current_context_env
        {
          :repository_identifier    => repository.identifier,
          :original_repository_path => command.identifier,
          :current_user_id          => user.try(:id),
        }
      end

    end
  end
end
