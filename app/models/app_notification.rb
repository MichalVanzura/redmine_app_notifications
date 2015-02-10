class AppNotification < ActiveRecord::Base
	belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
	belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
	belongs_to :issue
	belongs_to :journal

	def deliver(message_text)
		unless Setting.plugin_redmine_app_notifications['faye_server_adress'].empty?
			channel = "/notifications/private/#{recipient.id}"
			message = {:channel => channel, :data => { count: AppNotification.where(recipient_id: recipient.id, viewed: false).count, message: message_text, id: id}}
			uri = URI.parse(Setting.plugin_redmine_app_notifications['faye_server_adress'])
			Net::HTTP.post_form(uri, :message => message.to_json)
		end
	end
end
