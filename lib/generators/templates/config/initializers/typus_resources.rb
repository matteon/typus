Typus::Resource.setup do |config|
  config.default_action_on_item = 'edit'
  config.action_after_save = 'edit'

  # config.only_user_items = true

  config.per_page = 30
end
