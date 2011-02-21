module SmegHead
  Rails::Railtie::ABSTRACT_RAILTIES << "SmegHead::Plugin"
  class Plugin < Rails::Railtie

    class << self

      def metadata
        @metadata ||= begin
          if superclass.respond_to?(:metadata)
            superclass.metadata.dup
          else
            {}
          end
        end
      end

      def define_metadata_accessors(*args)
        options = args.extract_options!
        args.each do |attribute_name|
          method_name = [options[:prefix], attribute_name, options[:suffix]].compact.join("_")
          class_eval <<-EOF, __FILE__, __LINE__
            def self.#{method_name}(value = nil)
              if value.nil?
                metadata[#{attribute_name.inspect}]
              else
                metadata[#{attribute_name.inspect}] = value
              end
            end
          EOF
        end
      end

      delegate :subscribe, :unsubscribe, :to => SmegHead

      def extend_model(model_name, mixin)
        ActionDispatch::Callbacks.to_prepare do
          model_name.to_s.contantize.send :include, mixin
        end
      end

    end

    define_metadata_accessors :name, :author, :version, :url, :prefix => "plugin"

  end
end