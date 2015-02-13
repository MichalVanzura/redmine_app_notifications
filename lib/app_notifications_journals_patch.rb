module AppNotificationsJournalsPatch
  extend ActiveSupport::Concern

  included do
    after_create :create_app_notifications_after_create_journal
  end

  def create_app_notifications_after_create_journal

    if notify? && (Setting.plugin_redmine_app_notifications.include?('issue_updated') ||
        (Setting.plugin_redmine_app_notifications.include?('issue_note_added') && journal.notes.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_status_updated') && journal.new_status.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_assigned_to_updated') && journal.detail_for_attribute('assigned_to_id').present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
      )
      issue = journalized.reload
      to_users = notified_users
      cc_users = notified_watchers - to_users
      issue = journalized
      @author = user
      @issue = issue
      @users = to_users + cc_users

      @users.each do |user|
        if user.app_notification && user.id != @author.id
          notification = AppNotification.create({
            :journal_id => id,
            :issue_id => @issue.id,
            :author_id => @author.id,
            :recipient_id => user.id,
          })
          notification.deliver
        end
      end
    end
  end
end

Journal.send(:include, AppNotificationsJournalsPatch)
