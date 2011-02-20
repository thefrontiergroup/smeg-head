module SmegHead
  # Implements a simplified Pub / Sub hub for in-application notifications.
  # Used inside smeghead as a general replacement for observers and a way
  # for items to hook into events.
  class Hub

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

    # A tree-like structure that mains a list of subscriptions and sublevels of subscriptions,
    # useful for relatively efficient management (time wise) of subscriptions).
    class Subscriptions

      # Creates a new subscription with an empty list of subscriptions and an empty subkeys mapping.
      def initialize
        @subscriptions = []
        @subkeys    = {}
      end

      def call(context = {})
        path_parts  = context[:path_parts].dup
        @subscriptions.each { |subscription| subscription.call context }
        if (subkey = @subkeys[path_parts.shift])
          subkey.call context.merge(:path_parts => path_parts)
        end
        true
      end

      # Adds a new subscription to this subscriptions list.
      # @param [Subscription] subscription the new subscription to add
      def add(subscription)
        @subscriptions << subscription
      end

      # Removes a given subscription from this level.
      # @param [Subscription] subscription the old subscription to remove
      def delete(subscription)
        @subscriptions.delete subscription
      end

      # Gets the sublevel with the given key, initializing a new
      # sublevel if it is as of yet unknown.
      # @param [String] key the key of the given sublevel
      # @return [Subscriptions] the returned subscription level
      def sublevel(key)
        @subkeys[key] ||= Subscriptions.new
      end

      # Given a list of subkeys, will return the association sublevel.
      # @param [Array<String>] parts the list of path-parts to reach the desired sublevel.
      # @return [Subscriptions] the given sublevel subscriptions object.
      def sublevel_at(*parts)
        parts.flatten.inject(self) do |level, part|
          level.sublevel part
        end
      end

    end

    class << self

      # Gets the current application wide hub, initializing
      # a new one if it hasn't been set yet.
      # @return [Hub] the subscription hub
      def hub
        @hub ||= new
      end

      # We delegate the subscription management methods to the default hub.
      delegate :subscribe, :unsubscribe, :publish, :to => :hub

    end

    attr_reader :subscriptions

    # Initializes the given hub with an empty set of subscriptions.
    def initialize
      @subscriptions = Subscriptions.new
    end

    # Subscribes to a given path string and either a proc callback or
    # any object responding to #call.
    # @param [String] path the subscription path
    # @param [#call] object if present, the callback to invoke
    # @param [Proc] blk the block to use for the callback (if the object is nil)
    # @example Subscribing with a block
    #   hub.subscribe 'hello:world' do |ctx|
    #     puts "Context is #{ctx.inspect}"
    #   end
    # @example Subscribing with an object
    #   hub.subscribe 'hello:world', MyCallableClass
    def subscribe(path, object = nil, &blk)
      subscription = Subscription.new(path, (object || blk))
      level        = subscriptions.sublevel_at subscription.to_subscribe_keys
      level.add subscription
      subscription
    end

    # Deletes the given subscription from this pub sub hub.
    # @param [Subscription] subscription the subscription to delete
    # @return [Subscription] the deleted subscription
    def unsubscribe(subscription)
      return if subscription.blank?
      level = subscriptions.sublevel_at subscription.to_subscribe_keys
      level.delete subscription
      subscription
    end

    # Publishes a message to the given path and with a given hash context.
    # @param [String] path the pubsub path
    # @param [Hash{Symbol => Object}] context the message context
    # @example Publishing a message
    #   hub.publish 'hello:world', :hello => 'world'
    def publish(path, context = {})
      path_parts = path.split(":")
      context = merge_path_context path_parts, context
      # Actually handle publishing the subscription
      subscriptions.call context.merge :path_parts => path_parts, :full_path => path
    end

    def merge_path_context(path_parts, context)
      if context.has_key?(:path_keys)
        path_keys = Array(con  text.delete(:path_keys))
        context   = context.dup
        path_keys.each_with_index do |part, idx|
          next if part.blank? or part.to_s == "_"
          context[part.to_sym] = path_parts[idx]
        end
      end
      context
    end

  end
end
