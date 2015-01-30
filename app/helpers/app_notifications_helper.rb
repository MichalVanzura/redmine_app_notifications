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
end
