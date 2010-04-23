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

      def date_format(attribute = :default)
        Typus::Configuration.config[model.model_name]['fields']['options']['date_formats'][attribute.to_s].to_sym
      rescue
        :db
      end

    end

  end

end
