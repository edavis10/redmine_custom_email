# Wrap the QuestionMailer actions so they do not send emails
module CustomEmail
  module Patch
    module QuestionMailer
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        # Make sure the email isn't delivered
        def deliver!(mail = @mail)
          type_header = mail.header["x-redmine-type"] || mail.header["x-chiliproject-type"]
          
          if type_header.present? && type_header.to_s == "Question"
            # Reminder email so allow sending
            super
          else
            # Question details email, don't send
            return true
          end
        end
      end
      
    end
  end
end

