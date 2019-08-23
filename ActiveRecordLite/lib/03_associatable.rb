require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    option = { class_name: name.to_s.singularize.camelize, foreign_key: ("#{name}" + '_id').to_sym, primary_key: :id }
    #define instance variables for option keys set to values
    option.each_key do |key|
      self.send("#{key}=", options[key] || option[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    option = { class_name: name.to_s.singularize.camelize, foreign_key: ("#{self_class_name}" + '_id').downcase.to_sym, primary_key: :id }
    option.each_key do |key|
      self.send("#{key}=", options[key] || option[key])
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    options = @aesop[name]
    define_method(name) do  
      model_class = options.model_class  
      f_key = options.send(:foreign_key)
      f_key_val = self.send(f_key)
      # debugger
      model_class
        .where(options.primary_key => f_key_val).first
    end
  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do  
      model_class = options.model_class  
      f_key = options.send(:primary_key)
      f_key_val = self.send(f_key)
      # debugger
      model_class
        .where(options.foreign_key => f_key_val)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @aesop ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
