# Redmine App Notifications

App notifications plugin provides simple in application notifications for Redmine. It can replace default e-mail notifications.

## Installation and Setup

1. Follow the Redmine plugin installation steps at: http://www.redmine.org/wiki/redmine/Plugins
2. Run the plugin migrations `rake redmine:plugins:migrate RAILS_ENV=production`
3. Optional if you want to use Faye for server to client notifications
  1. Install the Thin server `gem install thin` or configure faye.ru accordingly to the server you use. See https://github.com/faye/faye-websocket-ruby#running-your-socket-application for more details.
  2. Copy the `faye_for_redmine` file to `/etc/init.d`
  3. Modify `/etc/init.d/faye_for_redmine` to at least fill the right value for `IN_APP_NOTIFICATION_ROOT_PATH`
  4. Makes the script starts at boot `cd /etc/init.d && update-rc.d faye_for_redmine defaults`
  2. Start the Faye server `/etc/init.d/faye_for_redmine start` (you can stop it with `stop` instead of `start`).
  3. In Administration > Plugins > Configure, modify `ip_address_or_name_of_your_server` to match your server IP address or name
4. Restart your Redmine web server
5. Login and configure the plugin (Administration > Plugins > Configure)
6. Enable In App Notifications in user account settings -> preferences
