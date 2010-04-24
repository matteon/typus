module Admin

  module FiltersHelper

    def filters

      typus_filters = @resource.filters
      return if typus_filters.empty?

      current_request = request.env['QUERY_STRING'] || []

      filters = typus_filters.map do |key, value|
        case value
        when :boolean then boolean_filter(current_request, key)
        when :string then string_filter(current_request, key)
        when :date, :datetime then date_filter(current_request, key)
        when :belongs_to then relationship_filter(current_request, key)
        when :has_many, :has_and_belongs_to_many then
          relationship_filter(current_request, key, true)
        when nil then
          # Do nothing. This is ugly but for now it's ok.
        else
          string_filter(current_request, key)
        end
      end

      html = <<-HTML
<div id="filters">
  <ul>
    #{filters}
  </ul>
</div>
      HTML

      return raw(html)

    end

    def build_filters(filter, items)
      render "admin/helpers/filters/filters", :items => items, :attribute => filter
    end

    def relationship_filter(request, filter, habtm = false)
      att_assoc = @resource.reflect_on_association(filter.to_sym)
      class_name = att_assoc.options[:class_name] || ((habtm) ? filter.classify : filter.capitalize.camelize)
      model = class_name.constantize
      related_fk = (habtm) ? filter : att_assoc.primary_key_name

      params_without_filter = params.dup
      %w( controller action page ).each { |p| params_without_filter.delete(p) }
      params_without_filter.delete(related_fk)

      items = {}
      model.all(:order => model.typus_order_by).each do |m|
        items[m.id] = m.to_label
      end

      build_filters(filter, items)
    end

    def date_filter(request, filter)
      items = {}

      %w( today last_few_days last_7_days last_30_days ).map do |timeline|
        items[timeline] = _(timeline.humanize)
      end

      build_filters(filter, items)
    end

    def boolean_filter(request, filter)
      items = @resource.boolean(filter)
      build_filters(filter, items)
    end

    def string_filter(request, filter)
      values = @resource::const_get("#{filter.to_s.upcase}")

      if values.kind_of?(Hash)
        items = values.invert
      else
        items = {}
        values.each do |value|
          items[value] = value
        end
      end

      build_filters(filter, items)
    end

  end

end
