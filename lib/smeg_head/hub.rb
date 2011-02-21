require 'smeg_head/subscription'
require 'smeg_head/subscriptions'

module SmegHead

  class << self

    attr_writer :hub

    # Gets the current application wide hub, initializing
    # a new one if it hasn't been set yet.
    # @return [Hub] the subscription hub
    def hub
      @hub ||= Hub.new
    end

    # We delegate the subscription management methods to the default hub.
    delegate :subscribe, :unsubscribe, :publish, :to => :hub

  end

  # Implements a simplified Pub / Sub hub for in-application notifications.
  # Used inside smeghead as a general replacement for observers and a way
  # for items to hook into events.
  class Hub

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
      if object and not object.respond_to?(:call)
        raise ArgumentError, "you provided an object as an argument but it doesn't respond to #call"
      end
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

    private

    def merge_path_context(path_parts, context)
      if context.has_key?(:path_keys)
        context   = context.dup
        path_keys = Array(context.delete(:path_keys))
        path_keys.each_with_index do |part, idx|
          next if part.blank?
          context[part.to_sym] = path_parts[idx]
        end
      end
      context
    end

  end
end
