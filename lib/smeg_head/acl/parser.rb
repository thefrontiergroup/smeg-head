require 'parslet'

module SmegHead
  module ACL
    class Parser < Parslet::Parser

      def self.parse(text)
        parser = new
        parser.parse text
      rescue Parslet::ParseFailed => error
        puts error, parser.root.error_tree
      end

      def collection_of(type, max = 5)
        type >> (comma_seperator >> type).repeat(0, max)
      end

      def one_of(strings)
        strings.map { |v| str(v) }.inject(:|)
      end

      def all_of_type(type, name = :type)
        str('all').as(:all) >> spaces >> type.as(name)  >> str('s').maybe
      end

      rule(:space)           { (str(' ') | str('  ')) }
      rule(:spaces?)         { space.repeat }
      rule(:spaces)          { space.repeat 1 }
      rule(:comma_seperator) { str(',') >> spaces }
      rule(:wildcard)        { str('*') }
      rule(:alphanumeric)    { match['A-Za-z0-9'] }
      rule(:characters)      { alphanumeric | match['\-\_'] }
      rule(:ref_part)        { alphanumeric >> characters.repeat }
      rule(:ref_suffix)      { str('/').maybe >> characters.repeat >> wildcard }
      rule(:ref_name)        { ref_part >> (str('/') >> ref_part).repeat }
      rule(:target_type)     { str('branch') | str('tag') | str('refs') }
      rule(:target_matcher)  { wildcard | (wildcard.maybe >> ref_name >> ref_suffix.maybe) }
      rule(:specific_target) { target_type.as(:type) >> spaces >> target_matcher.as(:matcher) }
      rule(:aot_target)      { all_of_type target_type }
      rule(:target)          { specific_target | aot_target }
      rule(:actor_type)      { one_of %w(user group) }
      rule(:specific_actor)  { actor_type.as(:type) >> spaces >> (alphanumeric >> characters.repeat).as(:name) }
      rule(:aot_actors)      { str('collaborators').as(:type) | all_of_type(actor_type) }
      rule(:actor)           { aot_actors | specific_actor }
      rule(:action)          { one_of %w(push pull destroy create all) }
      rule(:verb)            { (str('allow') | str('deny')) }
      rule(:newline)         { str("\n") >> str("\r").maybe }

      rule(:expression) do
        verb.as(:verb) >>
        spaces >>
        collection_of(action).as(:actions) >>
        spaces >> str('from') >> spaces >>
        collection_of(actor).as(:actors) >>
        spaces >> str('to') >> spaces >>
        collection_of(target).as(:targets)
      end

      rule(:line) { spaces? >> expression >> spaces? }

      rule(:lines) { (line >> newline).repeat >> line.maybe }

      root :lines

    end
  end
end