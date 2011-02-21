module SmegHead
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
end