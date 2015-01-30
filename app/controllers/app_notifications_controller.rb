class AppNotificationsController < ApplicationController
  unloadable
  helper :app_notifications
  include AppNotificationsHelper

  def index
    respond_to do |format|
      format.html do
        if request.xhr?
          @app_notifications = AppNotification.includes(:issue, :author, :journal).where(recipient_id: User.current.id).order("created_on desc").limit(5)
          render :partial => "ajax"
        end
        if !params.has_key?(:viewed) && !params.has_key?(:new) && !params.has_key?(:commit) 
          @viewed = true
          @new = true
        else
          params.has_key?(:viewed) ? @viewed = params['viewed'] : @viewed = false
          params.has_key?(:new) ? @new = params['new'] : @new = false
        end

        @app_notifications = query_notification(User.current.id, @viewed, @new)
        @limit = 10
        @app_notifications_pages = Paginator.new @app_notifications.count, @limit, params['page']
        @offset ||= @app_notifications_pages.offset
        @app_notifications.limit(@limit).offset(@offset)
      end
    end
  end

  def view
    AppNotification.update(params[:id], :viewed => true)
    if request.xhr?
      notification = AppNotification.find(params[:id])
      if notification.journal.present?
        render :partial => 'issues/issue_edit', :formats => [:html], :locals => { :notification => notification, :journal => notification.journal }
      else
        render :partial => 'issues/issue_add', :formats => [:html], :locals => { :notification => notification }
      end
    else
      redirect_to :controller => 'issues', :action => 'show', :id => params[:issue_id], :anchor => params[:anchor]
    end
  end

  def view_all
    AppNotification.where(:recipient_id => User.current.id, :viewed => false).update_all( :viewed => true )
    redirect_to :action => 'index'
  end
end
