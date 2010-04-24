module AdminHelper

  def typus_block(resource = @resource.to_resource, partial = params[:action])

    partials_path = "admin/#{resource}"
    resources_partials_path = "admin/resources"

    partials = ActionController::Base.view_paths.map do |view_path|
      Dir["#{view_path}/#{partials_path}/*"].map { |f| File.basename(f, '.html.erb') }
    end.flatten
    resources_partials = Dir[Rails.root.join("app/views/#{resources_partials_path}/*")].map do |file|
                           File.basename(file, ".html.erb")
                         end

    path = if partials.include?("_#{partial}") then partials_path
           elsif resources_partials.include?(partial) then resources_partials_path
           end

    render "#{path}/#{partial}" if path

  end

  def page_title
    (Typus.admin_title + " - " + @page_title.join(" &rsaquo; ")).html_safe
  end

  def header

    links = []

    unless params[:controller] == 'admin/dashboard'
      links << (link_to_unless_current _("Dashboard"), admin_dashboard_path)
    end

    Typus.models_on_header.each do |model|
      klass = Typus::AbstractModel.new(model)
      links << (link_to_unless_current model.model_name.human.pluralize, :controller => "/admin/#{model.tableize}")
    end

    if Rails.application.routes.routes.map(&:name).include?(:root)
      links << (link_to _("View site"), root_path, :target => 'blank')
    end

    render "admin/helpers/header", 
           :links => links

  end

  def login_info(user = @current_user)

    return if user.kind_of?(AdminUserFake)

    admin_edit_typus_user_path = { :controller => "/admin/#{Typus.user_class.to_resource}", 
                                   :action => 'edit', 
                                   :id => user.id }

    message = _("Are you sure you want to sign out and end your session?")

    user_details = if user.can?('edit', Typus.user_class_name)
                     link_to user.name, admin_edit_typus_user_path
                   else
                     user.name
                   end

    render "admin/helpers/login_info", 
           :message => message, 
           :user_details => user_details

  end

  def display_flash_message(message = flash)

    return if message.empty?
    flash_type = message.keys.first

    render "admin/helpers/flash_message", 
           :flash_type => flash_type, 
           :message => message

  end

end
