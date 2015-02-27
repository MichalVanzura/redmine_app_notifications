class AppNotificationsController < ApplicationController
  unloadable
  # helper :app_notifications
  # include AppNotificationsHelper

  def index
    @app_notifications = AppNotification.includes(:issue, :author, :journal).where(recipient_id: User.current.id).order("created_on desc")
    if request.xhr?
      @app_notifications = @app_notifications.limit(5)
      render :partial => "ajax"
    end

    if !params.has_key?(:viewed) && !params.has_key?(:new) && !params.has_key?(:commit) 
      @viewed = false
      @new = true
    else
      params.has_key?(:viewed) ? @viewed = params['viewed'] : @viewed = false
      params.has_key?(:new) ? @new = params['new'] : @new = false
    end

    if(!@viewed && !@new)
      return @app_notifications = []
    end
    if(@viewed != @new)
      @app_notifications = @app_notifications.where(viewed: true) if @viewed
      @app_notifications = @app_notifications.where(viewed: false) if @new
    end
    @limit = 10
    @app_notifications_pages = Paginator.new @app_notifications.count, @limit, params['page']
    @offset ||= @app_notifications_pages.offset
    @app_notifications = @app_notifications.limit(@limit).offset(@offset)
  end

  def view
    @notification = AppNotification.find(params[:id])
    if @notification.recipient == User.current 
      AppNotification.update(@notification, :viewed => true)
      if request.xhr?
        if @notification.is_edited?
          render :partial => 'issues/issue_edit', :formats => [:html], :locals => { :notification => @notification, :journal => @notification.journal }
        else
          render :partial => 'issues/issue_add', :formats => [:html], :locals => { :notification => @notification }
        end
      else
        redirect_to :controller => 'issues', :action => 'show', :id => params[:issue_id], :anchor => params[:anchor]
      end
    end
  end

  def view_all
    AppNotification.where(:recipient_id => User.current.id, :viewed => false).update_all( :viewed => true )
    redirect_to :action => 'index'
  end
end
