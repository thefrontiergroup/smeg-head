module SmegHead
  module ACL

    class Actor < Struct.new(:type, :name)

      def collaborators?
        type == :collaborators
      end

      def all?
        name.nil?
      end

      def self.from_hash(hash)
        if hash[:all] == 'all'
          new hash[:type].to_sym, nil
        else
          new hash[:type].to_sym, hash[:name].to_s.presence
        end
      end

      def matches?(user, repository)
        case type
        when :group
          if all?
            (repository.groups & user.groups).any?
          else
            user.groups.map(&:name).include?(name)
          end
        when :user
          all? || name == user.login
        when :collaborators
          true # User is assumed to be a collaborator.
        end
      end

    end

    class Action < Struct.new(:name)

      def initialize(value)
        super value.to_sym
      end

      def matches?(action, repository)
        name == :all or name == action
      end

    end

    class Target < Struct.new(:type, :matcher)

      # Given a string ref, checks if it matches this target.
      def matches?(ref, repository)
        return (type == :ref or type == ref.type) if all?
        case type
        when :branch, :tag
          type == ref.type && File.fnmatch(matcher.to_s, ref.name)
        when :ref
          File.fnmatch(matcher.to_s, ref.full)
        end
      end

      def self.from_hash(hash)
        if hash[:all] == 'all'
          new hash[:type].to_sym, nil
        else
          new hash[:type].to_sym, hash[:matcher].to_s.presence
        end
      end

    end

    class Rule 

      attr_reader :verb, :targets, :actors, :actions

      def initialize(verb, targets, actors, actions)
        @verb    = verb.to_sym
        @targets = Array.wrap(targets).map { |t| Target.from_hash(t) }
        @actors  = Array.wrap(actors).map  { |t| Actor.from_hash(t) }
        @actions = Array.wrap(actions).map { |a| Action.new(a) }
      end

      def self.from_hash(hash)
        new hash[:verb], hash[:targets], hash[:actors], hash[:actions]
      end

      def matches?(action, user, ref, repository)
        any_match?(actions, action, repository) and any_match?(targets, ref, repository) and any_match?(actors, user, repository)
      end

      def to_boolean
        verb == :allow
      end

      def any_match?(collection, object, repository)
        collection.any? { |v| v.matches?(object, repository) }
      end

    end

    class PermissionList
      attr_reader :rules

      def initialize(rules)
        @rules = Array.wrap(rules).map { |v| Rule.from_hash(v) }
      end

      # Checks whether the given user can perform a specified action on the specified ref.
      def can?(action, user, ref, repository)
        rules.each do |rule|
          return rule.to_boolean if rule.matches?(action, user, ref, repository)
        end
        false # False is the default fallback.
      end

      def self.parse(rules)
        new parser.parse(rules)
      end

      def self.parser
        @parser ||= SmegHead::ACL::Parser.new
      end

    end

  end
end
