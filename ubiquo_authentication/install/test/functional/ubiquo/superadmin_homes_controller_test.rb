require File.dirname(__FILE__) + "/../../test_helper.rb"
class Ubiquo::SuperadminHomesControllerTest < ActionController::TestCase

  test "should get show if superadmin" do
    login(:admin)
    assert assigns(:ubiquo_user).is_superadmin?
    get :show
    assert_response :ok
  end

  test "shouldnt get show if not superadmin" do
    login(:eduard)
    assert assigns(:ubiquo_user).is_superadmin?
    get :show
    assert_redirected_to ubiquo.login_path
  end
end
