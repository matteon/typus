require "typus/orm/active_record"

if defined?(ActiveRecord)
  ActiveRecord::Base.extend Typus::Orm::ClassMethods
  ActiveRecord::Base.send :include, Typus::Orm::InstanceMethods
end
