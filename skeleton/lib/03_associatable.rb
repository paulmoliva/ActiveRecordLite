require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    Object.const_get(@class_name)
  end

  def table_name
    @class_name.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.keys.each{|k| instance_variable_set("@#{k}", options[k])}
    @primary_key ||= :id
    @foreign_key ||= (name.to_s.underscore + "_id").to_sym
    @class_name ||= name.to_s.camelize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, classname, options = {})
    options.keys.each{|k| instance_variable_set("@#{k}", options[k])}
    @primary_key ||= :id
    @foreign_key ||= (classname.to_s.singularize.underscore + "_id").to_sym
    @class_name ||= name.to_s.camelize.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options if options.is_a?(BelongsToOptions)
    define_method(name) do
      foreign_key_value = send(options.foreign_key)
      target_model_class = options.model_class
      target_model_class.where({options.primary_key => foreign_key_value}).first
    end
  end

  def has_many(name, options_params = {})
    options = HasManyOptions.new(name, self.name, options_params)
    define_method(name) do
      primary_key_value = send(options.primary_key)
      target_model_class = options.model_class
      target_model_class.where({options.foreign_key => primary_key_value})
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
