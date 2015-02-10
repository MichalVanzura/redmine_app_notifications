require File.expand_path('../../test_helper', __FILE__)

class AppNotificationTest < ActiveSupport::TestCase
  
  FactoryGirl.define do
    factory :recipient, class: User do
      id 2
    end

    factory :issue, class: Issue do
      subject "Can't print recipes"
      description "Unable to print recipes"
    end

    factory :notification_001, class: AppNotification do
      id 1
      created_on "2015-01-24 16:41:41"
      viewed false
      association :recipient, strategy: :build
      association :issue, strategy: :build
    end
  end

  def setup
    @notification_001 = build_stubbed(:notification_001)
  end

  def test_deliver
    response = @notification_001.deliver("message")
    assert_equal response.code, "200"
    assert response.body.include? "notifications/private/2"
  end
end
