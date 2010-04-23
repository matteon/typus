module Typus

  class AbstractModel

    module GenericSupport

      def description
        Typus::Configuration.config[model.model_name]['description']
      end

    end

  end

end
