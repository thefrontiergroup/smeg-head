require 'smeg_head/hub'

module SmegHead
  # A simple hub you can use to completely disable the pub / sub process
  # but still record what happens.
  class MockHub < Hub

    class Publication < Struct.new(:path, :context)
    end

    attr_reader :subscriptions, :unsubscriptions, :publications

    def initialize
      super
      @subscriptions, @unsubscriptions, @publications = [], [], []
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
      subscriptions << subscription
      subscription
    end

    # Deletes the given subscription from this pub sub hub.
    # @param [Subscription] subscription the subscription to delete
    # @return [Subscription] the deleted subscription
    def unsubscribe(subscription)
      return if subscription.blank?
      subscriptions.delete subscription
      subscription
    end

    # Publishes a message to the given path and with a given hash context.
    # @param [String] path the pubsub path
    # @param [Hash{Symbol => Object}] context the message context
    # @example Publishing a message
    #   hub.publish 'hello:world', :hello => 'world'
    def publish(path, context = {})
      publications << Publication.new(path, context)
    end

  end
end