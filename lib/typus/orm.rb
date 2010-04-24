if defined?(ActiveRecord)
  require "typus/orm/active_record"
  ActiveRecord::Base.send :include, Typus::Orm::InstanceMethods
end
