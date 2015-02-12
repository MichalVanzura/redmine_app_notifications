require_dependency 'my_controller'

module AppNotificationsAccountPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :account, :in_app_option
    end
  end

  module InstanceMethods
    def account_with_in_app_option
      account = account_without_in_app_option
      User.safe_attributes 'app_notification', 'app_notification_desktop'
      return account
    end
  end
end

MyController.send(:include, AppNotificationsAccountPatch)
