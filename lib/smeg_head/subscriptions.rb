module SmegHead
  # SmegHead::Subscriptions implements a simple tree-like structure for handling subscriptions, facilitating
  # the efficient depth-first processing of callbacks based on a given path.
  #
  # Each level of the tree is composed of some callbacks as well as a set of sublevels, each represented by
  # part of a subscription namespace. Namely, given a key of "a:b:c", there will be four levels:
  #
  # 1. The root level - Currently, nothing subscribes to this level
  # 2. The "a" level - this is nested under the root level.
  # 3. The "b" level - this is nested under the "a" level.
  # 4. The "c" level - this is nested under the "b" level.
  #
  # When an event is published to "a:b:c", the top level Subscriptions instance will recursively ``#call`` the
  # child levels, breaking if at any point a subscription returns false. Ideally, this means that for a normal
  # event, we will get events (if present) invoked on all four levels, allowing a nice and structured event
  # dispatch.
  class Subscriptions

    # Creates a new subscription with an empty list of subscriptions and an empty subkeys mapping.
    def initialize
      @subscriptions = []
      @subkeys    = {}
    end

    # Given a specified context, calls all nested matching subcontexts and then invokes the
    # callbacks on this level, breaking if it encounters false (like terminators in AS callbacks).
    #
    # This means that if your subscription returns false, it will halt further callbacks. Also,
    # It also means that dispatching events are depth first based on the key. E.g., given a callback
    # key of "a:b:c", the callbacks for "a:b:c" will be called first followed by those for "a:b" and "a".
    #
    # @param [Hash] context the given context for this publish call
    # @option context [Array<String>] :path_parts an array of the current children keys to dispatch on
    def call(context = {})
      path_parts  = context[:path_parts].dup
      # Call the sublevel, breaking when a value returns false
      if path_parts.any? and (subkey = @subkeys[path_parts.shift])
        result = subkey.call context.merge(:path_parts => path_parts)
        return result if result == false
      end
      # Iterate over the subscriptions, breaking when one of them returns false
      @subscriptions.each do |subscription|
        return false if subscription.call(context) == false
      end
      # Otherwise, return nil
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