require File.dirname(__FILE__) + "/../../test_helper.rb"
class Ubiquo::SuperadminHomesControllerTest < ActionController::TestCase

  test "should get show if superadmin" do
    login(:admin)
    ubiquo_users(:admin).update_attribute :is_superadmin, true
    get :show
    assert_response :ok
  end

  test "shouldnt get show if not superadmin" do
    login(:eduard)
    get :show
    assert !ubiquo_users(:eduard).is_superadmin?
    assert_redirected_to ubiquo.login_path
  end
end
