require File.expand_path('../../test_helper', __FILE__)

class AppNotificationsControllerTest < ActionController::TestCase

  include IssuesHelper

	FactoryGirl.define do
    factory :user_001, class: User do
      created_on "2006-07-19 19:12:21 +02:00"
      status 1
      last_login_on "2006-07-19 22:57:52 +02:00"
      language "en"
      # password = admin
      salt "82090c953c4a0000a7db253b0691a6b4"
      hashed_password "b5b6ff9543bf1387374cdfa27a54c96d236a7150"
      updated_on "2006-07-19 22:57:52 +02:00"
      admin true
      mail "jane@somenet.foo"
      lastname "Smith"
      firstname "Jane"
      mail_notification "all"
      login "jane"
      type "User"
    end

    factory :user_002, class: User do
      created_on "2006-07-19 19:12:21 +02:00"
      status 1
      last_login_on "2006-07-19 22:57:52 +02:00"
      language "en"
      # password = jsmith
      salt "67eb4732624d5a7753dcea7ce0bb7d7d"
      hashed_password "bfbe06043353a677d0215b26a5800d128d5413bc"
      updated_on "2006-07-19 22:42:15 +02:00"
      admin false
      mail "asmith@somenet.foo"
      lastname "Smith"
      firstname "Arthur"
      mail_notification "all"
      login "asmith"
      type "User"
    end

    factory :project do
      created_on "2006-07-19 19:13:59 +02:00"
      name "eCookbook"
      updated_on "2006-07-19 22:53:01 +02:00"
      description "Recipes management application"
      homepage "http://ecookbook.somenet.foo/"
      is_public true
      identifier "ecookbook"
    end

    factory :issue_category do
      name "Printing"
    end

    factory :tracker do
      name "tracker"
    end

    factory :project_with_tracker, :parent => :project do
      name "project"
      trackers {[FactoryGirl.create(:tracker)]}
    end

    factory :issue_priority do
      name "priority"
    end

    factory :issue_status do
      name "status"
    end

    factory :issue_001, class: Issue do
      created_on "2015-02-03 13:10:07"
      updated_on "2015-02-03 13:10:55"
      association :priority, factory: :issue_priority, strategy: :build
      subject "Can't print recipes"
      association :category, factory: :issue_category, strategy: :build
      description "Unable to print recipes"
      association :status, factory: :issue_status, strategy: :build
      start_date "2015-02-03"
      due_date "2015-03-03"
      lock_version 3
    end

    factory :journal do
      created_on "2015-02-03 13:10:07"
      notes "Journal notes"
      journalized_type "Issue"
    end

    factory :notification_001, class: AppNotification do
      id 1
      created_on "2015-01-24 16:41:41"
      viewed false
    end

    factory :notification_002, class: AppNotification do
      id 2
      created_on "2015-02-03 13:10:07"
      viewed true
    end

    factory :notification_003, class: AppNotification do
      id 3
      created_on "2014-06-005 08:10:38"
      viewed true
    end

    factory :notification_004, class: AppNotification do
      id 4
      created_on "2014-06-005 08:15:58"
      viewed false
    end
  end

  def setup
    @user_001 = create(:user_001)
    @user_002 = create(:user_002)
    @project = create(:project_with_tracker)
    @issue_001 = create(:issue_001, project: @project, tracker: @project.trackers.first, author: @user_001, assigned_to: @user_002)
    @journal = create(:journal, user: @user_001, journalized: @issue_001)
    @notification_001 = create(:notification_001, author: @user_001, recipient: @user_002, issue: @issue_001)
    @notification_002 = create(:notification_002, author: @user_001, recipient: @user_002, issue: @issue_001)
    @notification_003 = create(:notification_003, author: @user_001, recipient: @user_002, issue: @issue_001, journal: @journal)
    @notification_004 = create(:notification_004, author: @user_001, recipient: @user_002, issue: @issue_001, journal: @journal)
  end

	def test_index
		get :index

		assert_response :success
		assert_template 'index'
	end

  def test_index_with_user
    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
      get :index

      assert_template partial: '_issue_add', count: 2
      assert_template partial: '_issue_edit', count: 2
      assert_equal 4, assigns(:app_notifications).count
    end
  end

	def test_index_with_user_filter_new  
    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
  		get :index, :new => true, :commit => 'Filter'

      assert_template partial: '_issue_add', count: 1
      assert_template partial: '_issue_edit', count: 1
  		assert_equal 2, assigns(:app_notifications).count
    end
	end

  def test_index_with_user_filter_viewed
    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
      get :index, :viewed => true, :commit => 'Filter'

      assert_template partial: '_issue_add', count: 1
      assert_template partial: '_issue_edit', count: 1
      assert_equal 2, assigns(:app_notifications).count
    end
  end

  def test_index_xhr
    xhr :get, :index

    assert_response :success
    assert_template 'ajax'
  end

  def test_index_xhr_with_user
    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
      xhr :get, :index

      assert_template partial: '_issue_ajax_add', count: 2
      assert_template partial: '_issue_ajax_edit', count: 2
      assert_equal 4, assigns(:app_notifications).count
    end
  end

  def test_view
    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
      assert !@notification_001.viewed
      get :view, :id => @notification_001.id, :issue_id => @issue_001.id

      assert AppNotification.find(@notification_001.id).viewed
      assert_response :redirect
    end
  end

  def test_view_xhr
    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
      xhr :get, :view, :id => @notification_001.id, :issue_id => @issue_001.id

      assert_template partial: '_issue_add', count: 1
    end
  end

  def test_view_all
    assert !@notification_001.viewed
    assert !@notification_004.viewed

    @request.session[:user_id] = @user_002.id
    with_current_user(@user_002) do
      post :view_all

      assert AppNotification.find(@notification_001.id).viewed
      assert AppNotification.find(@notification_004.id).viewed
      assert_response :redirect
    end
  end
end
