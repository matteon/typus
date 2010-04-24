module Typus

  class AbstractModel

    module GenericSupport

      def new(*args)
        model.new(*args)
      end

      def all(*args)
        model.all(*args)
      end

      def find(*args)
        exception("find(*args)")
      end

      def model_fields
        exception("model_fields")
      end

      def model_relationships
        exception("model_relationships")
      end

      def user_id?
        exception("user_id?")
      end

      def fields_for
        exception("fields_for")
      end

      def filters
        exception("filters")
      end

      def model_name
        exception("model_name")
      end

      def human_attribute_name(*args)
        exception("human_attribute_name(*args)")
      end

      def to_resource
        exception("to_resource")
      end

      def options_for(field)
        exception("options_for(field)")
      end

      def build_conditions(*args)
        exception("build_conditions(*args)")
      end

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

      def actions
        return [] if Typus::Configuration.config[model.model_name]['actions'].nil?
        Typus::Configuration.config[model.model_name]['actions'].keys.map do |key|
          Typus::Configuration.config[model.model_name]['actions'][key].extract_settings
        end.flatten
      rescue
        []
      end

      # Extended actions for this model on Typus.
      def actions_on(filter)
        Typus::Configuration.config[model.model_name]['actions'][filter.to_s].extract_settings
      rescue
        []
      end

      # Used for +search+, +relationships+
      def defaults_for(filter)
        data = Typus::Configuration.config[model.model_name][filter.to_s]
        return (!data.nil?) ? data.extract_settings : []
      end

      def field_options_for(filter)
        Typus::Configuration.config[model.model_name]['fields']['options'][filter.to_s].extract_settings.collect { |i| i.to_sym }
      rescue
        []
      end

      def reflect_on_all_associations(*args)
        model.reflect_on_all_associations(*args)
      end

      def reflect_on_association(*args)
        model.reflect_on_association(*args)
      end

      def boolean(attribute = :default)
        exception("boolean(attribute)")
      end

      def accessible_attributes(*args)
        model.accessible_attributes(*args)
      end

      private

      def exception(message)
        raise "Typus::AbstractModel##{message} not implemented on your ORM."
      end

    end

  end

end
