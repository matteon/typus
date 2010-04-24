module Admin

  module FormHelper

    def build_form(fields, form)

      options = { :form => form }

      returning(String.new) do |html|

        fields.each do |key, value|

          if template = @resource.template(key)
            html << typus_template_field(key, template, options)
            next
          end

          html << case value
                  when :belongs_to  then typus_belongs_to_field(key, options)
                  when :tree        then typus_tree_field(key, :form => options[:form])
                  when :boolean, :date, :datetime, :string, :text, :time,
                       :file, :password, :selector, :rich_text
                    typus_template_field(key, value, options)
                  else
                    typus_template_field(key, :string, options)
                  end
        end

      end

    end

    def form_partial
      resource = @resource.to_resource
      template_file = Rails.root.join("app/views/admin/#{resource}/_form.html.erb")
      partial = File.exists?(template_file) ? resource : "resources"
      return "admin/#{partial}/form"
    end

    # OPTIMIZE: Move html code to partial.
    def typus_tree_field(attribute, *args)

      options = args.extract_options!
      options[:items] ||= @resource.roots
      options[:attribute_virtual] ||= 'parent_id'

      form = options[:form]

      values = expand_tree_into_select_field(options[:items], options[:attribute_virtual])

      label_text = @resource.human_attribute_name(attribute)

      <<-HTML
  <li>
    #{form.label label_text}
    #{form.select options[:attribute_virtual], values, { :include_blank => true }}
  </li>
      HTML

    end

    # OPTIMIZE: Cleanup the case statement.
    def typus_relationships

      @back_to = url_for(:controller => params[:controller], :action => params[:action], :id => params[:id])

      returning(String.new) do |html|
        @resource.defaults_for(:relationships).each do |relationship|

          association = @resource.reflect_on_association(relationship.to_sym)

          next if @current_user.cannot?('read', association.class_name.constantize)

          case association.macro
          when :has_and_belongs_to_many
            html << typus_form_has_and_belongs_to_many(relationship)
          when :has_many
            if association.options[:through]
              # Here we will shot the relationship. Better this than raising an error.
            else
              html << typus_form_has_many(relationship)
            end
          when :has_one
            html << typus_form_has_one(relationship)
          end

        end
      end

    end

    def typus_template_field(attribute, template, options = {})

      template_name = "admin/templates/#{template}"

      custom_options = { :start_year => @resource.options_for(:start_year), 
                         :end_year => @resource.options_for(:end_year), 
                         :minute_step => @resource.options_for(:minute_step), 
                         :disabled => attribute_disabled?(attribute), 
                         :include_blank => true }

      render template_name, :resource => @resource, 
                            :attribute => attribute, 
                            :options => custom_options, 
                            :html_options => {}, 
                            :form => options[:form], 
                            :label_text => @resource.human_attribute_name(attribute)

    rescue ActionView::TemplateError => error
      message = <<-MSG
Missing translation file for `#{locale}.yml`.
Get it from `http://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/#{locale}.yml` and place it on `config/locales`.
      MSG
      raise message
    rescue Exception => error
      raise error
    end

    def attribute_disabled?(attribute)
      accessible = @resource.accessible_attributes
      return accessible.nil? ? false : !accessible.include?(attribute)
    end

    ##
    # Tree builder when model +acts_as_tree+
    #
    def expand_tree_into_select_field(items, attribute)
      returning(String.new) do |html|
        items.each do |item|
          html << %{<option #{"selected" if @item.send(attribute) == item.id} value="#{item.id}">#{"&nbsp;" * item.ancestors.size * 2} &#8627; #{item.to_label}</option>\n}
          html << expand_tree_into_select_field(item.children, attribute) unless item.children.empty?
        end
      end
    end

  end

end
