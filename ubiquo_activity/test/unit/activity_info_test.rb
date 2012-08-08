require File.dirname(__FILE__) + "/../test_helper.rb"

class ActivityInfoTest < ActiveSupport::TestCase

  test "should create activity info" do
    assert_difference "ActivityInfo.count" do
      activity_info = create_activity_info
      assert !activity_info.new_record?, "#{activity_info.errors.full_messages.to_sentence}"
    end
  end

  test "should create activity info with related object" do
    related_object = Versionable.create
    assert_difference "ActivityInfo.count" do
      activity_info = create_activity_info(:related_object => related_object,
                                           :action => 'update')
      assert !activity_info.new_record?, "#{activity_info.errors.full_messages.to_sentence}"
      assert_equal related_object, activity_info.related_object
    end
  end

  test "should return the related object name" do
    activity_info = create_activity_info(:related_object => Versionable.create!)
    assert_equal :versionable, activity_info.related_object_name

    activity_info.stubs(:related_object).returns(activity_info)
    assert_equal :activity_info, activity_info.related_object_name
  end

  test "should require controller" do
    assert_no_difference "ActivityInfo.count" do
      activity = create_activity_info :controller => nil
      assert activity.errors.include?(:controller)
    end
  end

  test "should require action" do
    assert_no_difference "ActivityInfo.count" do
      activity = create_activity_info :action => nil
      assert activity.errors.include?(:action)
    end
  end

  test "should require status" do
    assert_no_difference "ActivityInfo.count" do
      activity = create_activity_info :status => nil
      assert activity.errors.include?(:status)
    end
  end

  test "should require ubiquo_user_id" do
    assert_no_difference "ActivityInfo.count" do
      activity = create_activity_info :ubiquo_user_id => nil
      assert activity.errors.include?(:ubiquo_user_id)
    end
  end

  test "should return the request_params" do
    params = {:hi => :bye}
    activity_info = create_activity_info(:info => {:request_params => params})
    assert_equal params, activity_info.request_params
  end

  test "should recover the related_object using Version model" do
    related_object = Versionable.create!
    activity_info = create_activity_info(:related_object => related_object)

    assert related_object.destroy
    activity_info.reload
    assert_equal related_object.attributes, activity_info.related_object.attributes
  end

  test "should fail to recover the related_object" do
    related_object = Versionable.create!
    activity_info = create_activity_info(:related_object => related_object)

    assert related_object.destroy
    activity_info.reload
    Version.last.destroy

    assert_nil activity_info.related_object
    assert_equal related_object.id, activity_info.related_object_id
    assert_equal related_object.class.name, activity_info.related_object_type
  end

  test "should recover the related_object at the moment when the activity was created" do
    related_object = Versionable.create!(:title => 'foo_1')
    original_attributes = related_object.attributes
    activity_info = create_activity_info(:related_object => related_object)

    assert_difference('Version.count') do
      related_object.update_attributes :title => 'foo_2'
    end

    assert related_object.destroy
    activity_info.reload
    assert_equal original_attributes, activity_info.related_object.attributes
    assert_equal 'foo_1', activity_info.related_object.title
  end

  test "should filter by date" do
    ActivityInfo.delete_all
    activity1, activity2 = create_activity_info, create_activity_info
    activity1.update_column :created_at, 4.days.ago
    activity2 = create_activity_info
    activity2.update_column :created_at, 2.days.ago
    fake_activity = create_activity_info
    searched_activities = ActivityInfo.filtered_search({ "filter_date_start" => 3.days.ago,
                                                         "filter_date_end" => 1.days.ago,
                                                      })
    assert_equal_set [activity2], searched_activities
  end

  test "should filter by user" do
    ActivityInfo.delete_all
    searched_user = UbiquoUser.find_by_login("josep")
    activity1 = create_activity_info :ubiquo_user => searched_user
    activity2 = create_activity_info :ubiquo_user => UbiquoUser.find_by_login("eduard")
    searched_activities = ActivityInfo.filtered_search("filter_user" => searched_user.id)
    assert_equal_set [activity1], searched_activities
    assert_equal_set [], ActivityInfo.filtered_search("filter_user" => '100')
  end

  private

  def create_activity_info(options = { })
    default_options = {
      :controller => "tests_controller",
      :action => "create",
      :status => "successful",
      :ubiquo_user_id => 3,
    }
    ActivityInfo.create(default_options.merge(options))
  end
end
