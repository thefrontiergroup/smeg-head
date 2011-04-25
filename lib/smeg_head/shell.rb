module SmegHead
  module Shell

    class Error < StandardError; end

    autoload :Manager, 'smeg_head/shell/manager'
    autoload :Command, 'smeg_head/shell/command'

  end
end