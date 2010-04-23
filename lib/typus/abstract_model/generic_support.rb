module Typus

  class AbstractModel

    module GenericSupport

      def description
        Typus::Configuration.config[model.model_name]['description']
      end

      def export_formats
        data = Typus::Configuration.config[model.model_name]
        !data['export'].nil? ? data['export'].extract_settings : []
      end

    end

  end

end
