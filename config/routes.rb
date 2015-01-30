get 'app-notifications', :to => 'app_notifications#index'
get 'app-notifications/:id', :to => 'app_notifications#view'
post 'app-notifications/view-all', :to => 'app_notifications#view_all'
