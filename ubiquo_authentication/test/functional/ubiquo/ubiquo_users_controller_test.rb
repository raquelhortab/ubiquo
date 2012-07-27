require File.dirname(__FILE__) + "/../../test_helper.rb"

class Ubiquo::UbiquoUsersControllerTest < ActionController::TestCase
  fixtures :ubiquo_users
  setup :login

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:ubiquo_users)
  end

  def test_should_get_index_filtered_by_admin
    admin_ubiquo_users = [ubiquo_users(:admin), ubiquo_users(:superadmin)]
    get :index, :filter_admin => "1"
    assert_equal admin_ubiquo_users.to_set, UbiquoUser.filtered_search({"filter_admin" => "true"}).to_set
    non_admin_ubiquo_users = [ubiquo_users(:josep), ubiquo_users(:inactive), ubiquo_users(:eduard)]
    get :index, :filter_admin => "0"
    assert UbiquoUser.filtered_search({"filter_admin" => "false"}).to_set == non_admin_ubiquo_users.to_set
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => ubiquo_users(:josep).id
    assert_response :success
  end

  def test_should_create_ubiquo_user
    mailer = stub(:deliver)
    UbiquoUsersNotifier.expects(:confirm_creation).once.returns(mailer)
    assert_difference('UbiquoUser.count') do
      post :create, :send_confirm_creation => "1", :ubiquo_user => { :name => "name", :surname => "surname", :login => 'ubiquo_userlogin', :email => "test@test.com", :password => '123456', :password_confirmation => '123456', :is_admin => false, :is_active => false}
    end

    assert_redirected_to ubiquo.ubiquo_users_path
  end

  def test_shouldnt_create_ubiquo_user_if_wrong_ubiquo_user
    UbiquoUsersNotifier.expects(:confirm_creation).never
    assert_no_difference('UbiquoUser.count') do
      post :create, :ubiquo_user => { :login => nil }
    end
    assert_template "new"
  end

  def test_should_update_ubiquo_user
    user_attrs = {
      :name => "name", :surname => "surname", :login => 'newlogin',
      :email => "test@test.com", :password => 'newpass',
      :password_confirmation => 'newpass', :is_admin => false,
      :is_active => false
    }
    put :update, :id => ubiquo_users(:josep).id, :ubiquo_user => user_attrs
    assert_redirected_to ubiquo.ubiquo_users_path
  end

  def test_shouldnt_update_ubiquo_user_if_wrong_fields
    put :update, :id => ubiquo_users(:josep).id, :ubiquo_user => { :login => nil}
    assert_template "edit"
  end

  def test_should_destroy_ubiquo_user
    assert_difference('UbiquoUser.count', -1) do
      delete :destroy, :id => ubiquo_users(:josep).id
    end

    assert_redirected_to ubiquo.ubiquo_users_path
  end

end
