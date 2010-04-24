module Typus

  module Orm

    module InstanceMethods

      def owned_by?(user)
        send(Typus.user_fk) == user.id
      end

      # Determine if file attachment is blank, taking into account that
      # user may be using a Paperclip attachment without a _file_name
      # suffix
      # TODO: Test attachment_present? method.
      def attachment_present?(attribute)
        attribute = attribute.to_s
        if attribute.index('_file_name')
          !send(attribute).blank?
        elsif respond_to?("#{attribute}_file_name")
          !send("#{attribute}_file_name").blank?
        end
      end

    end

  end

end
