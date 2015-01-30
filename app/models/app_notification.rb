class AppNotification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :issue
  belongs_to :journal
end
