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

  def variable_from_name(name)
    name = name.gsub(/^(one|an?) /, '')
    :"@#{name.to_s.singularize.gsub(/\s+/, '_')}"
  end

  def store_as_variable!(name, object)
    instance_variable_set variable_from_name(name), object
  end
  
  def retreive_variable(name)
    var_name = variable_from_name(name)
    if instance_variable_defined? var_name
      instance_variable_get var_name
    else
      nil
    end
  end

end

World ObjectRecognitionHelpers