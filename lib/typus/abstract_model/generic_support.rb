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

      # We are able to define which template to use to render the attribute 
      # within the form
      def template(attribute)
        Typus::Configuration.config[model.model_name]['fields']['options']['templates'][attribute.to_s]
      rescue
        nil
      end

    end

  end

end
