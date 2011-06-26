module ObjectRecognitionHelpers

  def recognize_object_from_string(string)
    case string
    when /a valid ssh key/
      ExampleKeys.generate
    when /an invalid ssh key/
      ExampleKeys.known_bad_keys.choice
    end
  end

  def recognize_attribute_name(name)
    name.to_s.singularize.underscore.gsub(/\s+/, '_').to_sym
  end

  def recognize_model(name)
    name = name.gsub(/^(one|an?) /, '')
    name.to_s.singularize.gsub(/\s+/, '_').classify.constantize
  end

  def recognize_association(object, name)
    name = name.gsub(/^(one|an?) /, '')
    association_name = name.pluralize.gsub(/\s+/, '_').to_sym
    object.send association_name
  end

end

World ObjectRecognitionHelpers