module CustomEmailMailerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do

      helper :custom_email
    end
  end

  module InstanceMethods
  end
end
