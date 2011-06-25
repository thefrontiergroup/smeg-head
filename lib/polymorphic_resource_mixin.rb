module PolymorphicResourceMixin
  extend ActiveSupport::Concern

  module InstanceMethods

    protected

    def polymorphic_id_for(*types)
      types.each do |type|
        key_id = "#{type}_id".to_sym
        found_id = request.path_parameters[key_id]
        if found_id.present?
          yield type, found_id if block_given?
          return type, found_id
        end
      end
      raise ActiveRecord::RecordNotFound
    end

  end

end