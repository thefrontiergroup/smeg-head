module SmegHead
  class Hub

    class Subscription

      attr_reader :name, :callback

      def initialize(name, callback)
        @name            = name.to_s
        @callback        = callback
        @_subscribe_keys = @name.to_s.split(":")
      end

      def to_subscribe_keys
        @_subscribe_keys
      end

      def invoke!(subkeys, context)
        @callback.call context.merge(:subkeys => subkeys)
      end

    end

    class SubscriptionLevel

      def initialize
        @this_level = []
        @subkeys    = {}
      end

      def invoke!(path_parts, context = {})
        @this_level.each { |subscription| subscription.invoke! path_parts.dup, context  }
        if (subkey = @subkeys[path_parts.shift])
          subkey.invoke! path_parts, context
        end
      end

      def add(subscription)
        @this_level << subscription
      end

      def sublevel(key)
        @subkeys[key] ||= SubscriptionLevel.new
      end

      def delete(subscription)
        @this_level.delete_if { |s| s == subscription }
      end

    end

    class << self

      def hub
        @hub ||= new
      end

      delegate :subscribe, :unsubscribe, :publish, :to => :hub

    end

    attr_reader :subscriptions

    def initialize
      @subscriptions ||= SubscriptionLevel.new
    end

    def subscribe(path, object = nil, &blk)
      subscription = Subscription.new(path, (object || blk))
      level = subscriptions
      subscription.to_subscribe_keys.each do |key|
        level = level.sublevel key
      end
      level.add subscription
      subscription
    end

    def unsubscribe(subscription)
      return if subscription.blank?
      subscription.to_subscribe_keys.each do |key|
        level = level.sublevel key
        level.delete subscription
      end
      subscription
    end

    def publish(path, context = {})
      parts = path.split(":")
      subscriptions.invoke! parts, context
    end

  end
end
