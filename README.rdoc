= redmine_app_notifications

App notifications plugin provides simple in application notifications for Redmine. It can replace default e-mail notifications.

== Installation and Setup

1. Follow the Redmine plugin installation steps at: http://www.redmine.org/wiki/redmine/Plugins
2. Run the plugin migrations `rake db:migrate_plugins`
3. Optional if you want to use Faye for server to client notifications
  1. Install the Thin server `gem install thin` or configure faye.ru accordingly to the server you use. See https://github.com/faye/faye-websocket-ruby#running-your-socket-application for more details.
  2. Start the Faye server `rackup faye.ru -E production -s thin` or modify this to the server you want to use.
  3. If you choose to use another url than http://localhost:9292/faye do not forget to change the configuration accordingly (Administration > Plugins > Configure)
4. Restart your Redmine web server
5. Login and configure the plugin (Administration > Plugins > Configure)
6. Enable In App Notifications in user account settings -> preferences
