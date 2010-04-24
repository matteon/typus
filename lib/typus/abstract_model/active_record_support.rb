require "active_record"

module Typus

  class AbstractModel

    module ActiveRecordSupport

      def find(*args)
        model.find(*args)
      end

      def count(*args)
        model.count(*args)
      end

      def to_resource
        model.model_name.underscore.pluralize
      end

      def model_name
        model.model_name
      end

      def human_attribute_name(*args)
        model.human_attribute_name(*args)
      end

      # Return model fields as a OrderedHash
      def model_fields
        hash = ActiveSupport::OrderedHash.new
        model.columns.map { |u| hash[u.name.to_sym] = u.type.to_sym }
        return hash
      end

      def model_relationships
        hash = ActiveSupport::OrderedHash.new
        model.reflect_on_all_associations.map { |i| hash[i.name] = i.macro }
        return hash
      end

      def user_id?
        model.columns.map { |u| u.name }.include?(Typus.user_fk)
      end

      # Used for `order_by`.
      def order_by

        fields = defaults_for(:order_by)

        if fields.empty?
          "#{model.table_name}.id ASC"
        else
          fields.map do |field|
            field.include?('-') ? "#{model.table_name}.#{field.delete('-')} DESC" : "#{model.table_name}.#{field} ASC"
          end.join(', ')
        end

      end

      # Form and list fields
      def fields_for(filter)

        fields_with_type = ActiveSupport::OrderedHash.new

        begin
          fields = Typus::Configuration.config[model.model_name]['fields'][filter.to_s]
          fields = fields.extract_settings.collect { |f| f.to_sym }
        rescue
          return [] if filter == 'default'
          filter = 'default'
          retry
        end

        begin

          fields.each do |field|

            attribute_type = model_fields[field]

            if reflect_on_association(field)
              attribute_type = reflect_on_association(field).macro
            end

            if field_options_for(:selectors).include?(field)
              attribute_type = :selector
            end

            if field_options_for(:rich_text).include?(field)
              attribute_type = :rich_text
            end

            # Custom field_type depending on the attribute name.
            case field.to_s
              when 'parent', 'parent_id'  then attribute_type = :tree
              when /file_name/            then attribute_type = :file
              when /password/             then attribute_type = :password
              when 'position'             then attribute_type = :position
              when /\./                   then attribute_type = :transversal
            end

            # Set attribute type to file if accompanied by standard
            # paperclip attachment fields with its name
            paperclip_fields = ["#{field}_file_name".to_sym,
                                "#{field}_content_type".to_sym,
                                "#{field}_file_size".to_sym,
                                "#{field}_updated_at".to_sym]

            if (model_fields.keys & paperclip_fields).size == paperclip_fields.size
              attribute_type = :file
            end

            # And finally insert the field and the attribute_type 
            # into the fields_with_type ordered hash.
            fields_with_type[field.to_s] = attribute_type

          end

        rescue
          fields = Typus::Configuration.config[model.model_name]['fields']['default'].extract_settings
          retry
        end

        return fields_with_type

      end

      ##
      # Sidebar filters:
      #
      # - Booleans: true, false
      # - Datetime: today, last_few_days, last_7_days, last_30_days
      # - Integer & String: *_id and "selectors" (p.ej. category_id)
      #
      def build_conditions(params)

        conditions, joins = model.merge_conditions, []

        query_params = params.dup
        %w( action controller ).each { |param| query_params.delete(param) }

        # If a search is performed.
        if query_params[:search]
          query = ActiveRecord::Base.connection.quote_string(query_params[:search].downcase)
          search = typus_defaults_for(:search).map do |s|
                     ["LOWER(#{s}) LIKE '%#{query}%'"]
                   end
          conditions = model.merge_conditions(conditions, search.join(' OR '))
        end

        query_params.each do |key, value|

          filter_type = model_fields[key.to_sym] || model_relationships[key.to_sym]

          case filter_type
          when :boolean
            condition = { key => (value == 'true') ? true : false }
            conditions = model.merge_conditions(conditions, condition)
          when :datetime
            interval = case value
                       when 'today'         then Time.new.midnight..Time.new.midnight.tomorrow
                       when 'last_few_days' then 3.days.ago.midnight..Time.new.midnight.tomorrow
                       when 'last_7_days'   then 6.days.ago.midnight..Time.new.midnight.tomorrow
                       when 'last_30_days'  then Time.new.midnight.last_month..Time.new.midnight.tomorrow
                       end
            condition = ["#{key} BETWEEN ? AND ?", interval.first.to_s(:db), interval.last.to_s(:db)]
            conditions = model.merge_conditions(conditions, condition)
          when :date
            if value.is_a?(Hash)
              date_format = Date::DATE_FORMATS[typus_date_format(key)]

              begin
                unless value["from"].blank?
                  date_from = Date.strptime(value["from"], date_format)
                  conditions = model.merge_conditions(conditions, ["#{key} >= ?", date_from])
                end

                unless value["to"].blank?
                  date_to = Date.strptime(value["to"], date_format)
                  conditions = model.merge_conditions(conditions, ["#{key} <= ?", date_to])
                end
              rescue
              end
            else
              # TODO: Improve and test filters.
              interval = case value
                         when 'today'         then nil
                         when 'last_few_days' then 3.days.ago.to_date..Date.tomorrow
                         when 'last_7_days'   then 6.days.ago.midnight..Date.tomorrow
                         when 'last_30_days'  then (Date.today << 1)..Date.tomorrow
                         end
              if interval
                condition = ["#{key} BETWEEN ? AND ?", interval.first, interval.last]
              elsif value == 'today'
                condition = ["#{key} = ?", Date.today]
              end
              conditions = model.merge_conditions(conditions, condition)
            end
          when :integer, :string
            condition = { key => value }
            conditions = model.merge_conditions(conditions, condition)
          when :has_and_belongs_to_many
            condition = { key => { :id => value } }
            conditions = model.merge_conditions(conditions, condition)
            joins << key.to_sym
          end

        end

        return conditions, joins

      end

      # We should be able to overwrite options by model.
      def options_for(filter)

        data = Typus::Configuration.config[model.model_name]
        unless data['options'].nil?
          value = data['options'][filter.to_s] unless data['options'][filter.to_s].nil?
        end

        return (!value.nil?) ? value : Typus::Resource.send(filter)

      end

      # Typus sidebar filters.
      def filters

        fields_with_type = ActiveSupport::OrderedHash.new

        data = Typus::Configuration.config[model.model_name]['filters']
        return [] unless data
        fields = data.extract_settings.collect { |i| i.to_sym }

        fields.each do |field|
          attribute_type = model_fields[field.to_sym]
          if reflect_on_association(field.to_sym)
            attribute_type = reflect_on_association(field.to_sym).macro
          end
          fields_with_type[field.to_s] = attribute_type
        end

        return fields_with_type

      end

      # We are able to define our own booleans.
      def boolean(attribute = :default)

        begin
          boolean = Typus::Configuration.config[model.model_name]['fields']['options']['booleans'][attribute.to_s]
        rescue
          boolean = 'true, false'
        end

        return nil if boolean.nil?

        hash = ActiveSupport::OrderedHash.new

        mapping = boolean.kind_of?(Array) ? boolean : boolean.extract_settings
        hash[:true], hash[:false] = mapping.first, mapping.last
        hash.map { |k, v| hash[k] = v.humanize }

        return hash

      end

    end

  end

end
