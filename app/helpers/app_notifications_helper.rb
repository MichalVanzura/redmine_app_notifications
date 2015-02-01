require File.dirname(__FILE__) + '/../../../../app/helpers/issues_helper'

module AppNotificationsHelper
	include IssuesHelper

	def query_notification(recipient_id, viewed_n, new_n)
		@app_notifications = AppNotification.includes(:issue, :author, :journal).where(recipient_id: recipient_id).order("created_on desc")
		if(!viewed_n && !new_n)
			@app_notifications = @app_notifications.where("1 = 0")
		end
		if(viewed_n != new_n)
			@app_notifications = @app_notifications.where(viewed: true) if viewed_n
			@app_notifications = @app_notifications.where(viewed: false) if new_n
		end

		return @app_notifications
	end

	def send_notification(user, message, notification)
		unless Setting.plugin_redmine_app_notifications['faye_server_adress'].empty?
			channel = "/notifications/private/#{user.id}"
			message = {:channel => channel, :data => { count: AppNotification.where(recipient_id: user.id, viewed: false).count, message: message, id: notification.id}}
			uri = URI.parse(Setting.plugin_redmine_app_notifications['faye_server_adress'])
			Net::HTTP.post_form(uri, :message => message.to_json)
		end
	end
end
