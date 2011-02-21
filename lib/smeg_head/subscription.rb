module SmegHead
  # A general subscription in a given hub, including a name and a given callback
  # block. As part of this, it provides tools to make it easy to handle the subscriptions.
  class Subscription

    attr_reader :name, :callback

    # Initializes a new subscription with a given name and callback.
    # @param [String] name the name of this subscription
    # @param [#call] callback the callback for this subscription
    def initialize(name, callback)
      @name            = name.to_s
      @callback        = callback
      @_subscribe_keys = @name.to_s.split(":")
    end

    # Returns the list of subscription sublevel keys.
    # @return [Array<String>] the list of sublevel keys
    def to_subscribe_keys
      @_subscribe_keys
    end

    def call(context)
      @callback.call context
    end

    def to_proc
      proc { |ctx| call ctx }
    end

  end
end