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
          return true
        end
      end
      
    end
  end
end

