class AppNotificationsHookListener < Redmine::Hook::ViewListener

  render_on :view_my_account_preferences, :partial => "app_notifications/my_account_preferences" 
  render_on :view_layouts_base_html_head, :partial => "app_notifications/layouts_base_html_head"

  def controller_issues_edit_after_save(context={})
    journal = context[:journal]
  	if journal.notify? && (Setting.plugin_redmine_app_notifications.include?('issue_updated') ||
        (Setting.plugin_redmine_app_notifications.include?('issue_note_added') && journal.notes.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_status_updated') && journal.new_status.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_assigned_to_updated') && journal.detail_for_attribute('assigned_to_id').present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
      )
      issue = journal.journalized.reload
      to_users = journal.notified_users
      cc_users = journal.notified_watchers - to_users
      issue = journal.journalized
      @author = journal.user
      @issue = issue
      @users = to_users + cc_users
      @journal = journal

      @users.each do |user|
        if user.app_notification && user.id != @author.id
          notification = AppNotification.create({
            :journal_id => @journal.id,
            :issue_id => @issue.id,
            :author_id => @author.id,
            :recipient_id => user.id,
          })
          message = I18n.t(:text_issue_updated, :id => "##{@issue.id}", :author => h(@journal.user))
          notification.deliver(message)
        end
      end
    end
  end

  def controller_issues_new_after_save(context={})
    @issue = context[:issue]
    if Setting.plugin_redmine_app_notifications.include?('issue_added')
      to_users = @issue.notified_users
      cc_users = @issue.notified_watchers - to_users
      @author = @issue.author
      @users = to_users + cc_users

      @users.each do |user|
        if user.app_notification && user.id != @author.id
          notification = AppNotification.create({
            :issue_id => @issue.id,
            :author_id => @author.id,
            :recipient_id => user.id,
          })
          message = I18n.t(:text_issue_added, :id => "##{@issue.id}", :author => h(@author))
          notification.deliver(message)
        end
      end
    end
  end
end