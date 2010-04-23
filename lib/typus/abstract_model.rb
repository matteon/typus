module Typus

  class AbstractModel

    attr_accessor :model

    def initialize(model)

      model = self.class.lookup(model.to_s.camel_case) unless model.is_a?(Class)

      @model = model
      require "typus/abstract_model/generic_support"
      self.extend(GenericSupport)

      require "typus/abstract_model/active_record_support"
      self.extend(ActiveRecordSupport)

    end

  end

end
