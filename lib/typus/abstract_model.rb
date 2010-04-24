module Typus

  class AbstractModel

    attr_accessor :model

    def initialize(model)

      model = self.class.lookup(model.to_s.camelize) unless model.is_a?(Class)

      @model = model
      require "typus/abstract_model/generic_support"
      self.extend(GenericSupport)

      require "typus/abstract_model/active_record_support"
      self.extend(ActiveRecordSupport)

    end

    # Given a string +model_name+, finds the corresponding model class
    def self.lookup(model_name)

      # return nil if MerbAdmin[:excluded_models].include?(model_name)
      # begin
      model_name.constantize
      # Object.const_get(model_name)
      #rescue NameError
      #  raise "MerbAdmin could not find model #{model_name}"
      # end

=begin

      case Merb.orm
      when :activerecord
        model if superclasses(model).include?(ActiveRecord::Base)
      when :datamapper
        model if model.include?(DataMapper::Resource)
      when :sequel
        model if superclasses(model).include?(Sequel::Model)
      else
        nil
      end
=end

    end

  end

end
