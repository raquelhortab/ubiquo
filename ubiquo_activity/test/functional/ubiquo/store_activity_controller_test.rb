require File.dirname(__FILE__) + "/../../test_helper.rb"
require File.dirname(__FILE__) + "/../../test_support/url_helper.rb"

class Ubiquo::StoreActivityControllerTest < ActionController::TestCase
  include TestSupport::UrlHelper

  def test_should_register_successful_activity_info_in_create
    ActivityInfo.delete_all
    assert_difference 'ActivityInfo.count' do
      login_as(:josep)
      post :create, :versionable => {}
    end
    assert_equal "successful", ActivityInfo.first.status
    assert_equal "ubiquo/store_activity", ActivityInfo.first.controller
    assert_equal "create", ActivityInfo.first.action
    assert_equal ubiquo_users(:josep).id, ActivityInfo.first.ubiquo_user_id
  end

  def test_should_register_info_activity_info_in_publish
    ActivityInfo.delete_all
    versionable = Versionable.create
    assert_difference 'ActivityInfo.count' do
      login_as(:eduard)
      put :publish, :id => versionable.id
    end
    assert_equal "info", ActivityInfo.first.status
    assert_equal "ubiquo/store_activity", ActivityInfo.first.controller
    assert_equal "publish", ActivityInfo.first.action
    assert_equal ubiquo_users(:eduard).id, ActivityInfo.first.ubiquo_user_id
  end

  def test_should_register_error_activity_info_in_destroy
    ActivityInfo.delete_all
    versionable = Versionable.create
    assert_difference 'ActivityInfo.count' do
      login_as(:eduard)
      delete :destroy, :id => versionable.id
    end
    assert_equal "error", ActivityInfo.first.status
    assert_equal "ubiquo/store_activity", ActivityInfo.first.controller
    assert_equal "destroy", ActivityInfo.first.action
    assert_equal ubiquo_users(:eduard).id, ActivityInfo.first.ubiquo_user_id
  end

  def test_should_register_request_parameters
    self.stubs(:activity_info_log_request_params?).returns(true)
    assert_difference 'ActivityInfo.count' do
      login_as(:eduard)
      # 1 => "1" in rails 3
      post :create, :my_param => 1
    end
    activity_info = ActivityInfo.last
    assert_equal "1", activity_info.request_params[:my_param]
  end

  def test_should_register_request_parameters_filtered
    self.stubs(:activity_info_log_request_params?).returns(true)
    assert_difference 'ActivityInfo.count' do
      login_as(:eduard)
      post :create, :my_param => 1, :password => 'secret'
    end
    activity_info = ActivityInfo.last
    assert_equal "1", activity_info.request_params[:my_param]
    assert_equal "[FILTERED]", activity_info.request_params[:password]
  end

  protected

end

class Ubiquo::StoreActivityController < UbiquoController
  def create
    @versionable = Versionable.new params[:versionable]
    # versionable.save

    respond_to do |format|
      store_activity :successful, @versionable, { :title => "Test object - 12/06/09" }
      format.html { render :nothing => true }
    end
  end

  def publish
    @versionable = Versionable.find(params[:id])
    @versionable.publish
    # versionable.save

    respond_to do |format|
      store_activity :info, @versionable, { :message => "Test object published correctly" }
      format.html { render :nothing => true }
    end
  end

  def destroy
    @versionable = Versionable.find(params[:id])
    # versionable.destroy

    respond_to do |format|
      store_activity :error, @versionable, { :object_type => "Test", :object_id => 23 }
      format.html { render :nothing => true }
    end
  end
end

