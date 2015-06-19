include GravatarHelper::PublicMethods
include ERB::Util

class AppNotification < ActiveRecord::Base
	belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
	belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
	belongs_to :issue
	belongs_to :journal

	def deliver
		unless Setting.plugin_redmine_app_notifications['faye_server_adress'].empty?
			channel = "/notifications/private/#{recipient.id}"
			message = {:channel => channel, :data => { count: AppNotification.where(recipient_id: recipient.id, viewed: false).count, message: message_text, id: id, avatar: gravatar_url(author.mail, { :default => Setting.gravatar_default })}}
			uri = URI.parse(Setting.plugin_redmine_app_notifications['faye_server_adress'])
			Net::HTTP.post_form(uri, :message => message.to_json)
		end
	end

	def is_edited?
		journal.present?
	end

	def message_text
		if is_edited?
			I18n.t(:text_issue_updated, :id => "##{issue.id}", :author => author)
		else
			I18n.t(:text_issue_added, :id => "##{issue.id}", :author => author)
		end
	end
end
