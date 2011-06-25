require 'angry_shell'
require 'fileutils'

module SmegHead
  module Commandable

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

    def cmd(*args, &blk)
      options = args.extract_options!
      command = build_command(*args)
      AngryShell::Shell.new(options.merge(:cmd => command), &blk)
    end

    def logger
      Rails.logger
    end

  end
end