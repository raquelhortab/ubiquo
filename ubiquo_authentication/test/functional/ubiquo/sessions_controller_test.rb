require File.dirname(__FILE__) + "/../../test_helper.rb"
require 'ubiquo/sessions_controller'

class Ubiquo::SessionsControllerTest < ActionController::TestCase
  use_ubiquo_fixtures

  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  # include AuthenticatedTestHelper
  
  #fixtures :ubiquo_users

  def test_should_login_and_redirect
    post :create, :login => 'josep', :password => 'test'
    assert session[:ubiquo_user_id]
    assert_response :redirect
  end
  
  def test_should_not_login_for_inactive_accounts
    ubiquo_users(:josep).update_attribute(:is_active, false)
    
    post :create, :login => 'josep', :password => 'test'
    assert session[:ubiquo_user_id].nil?
    assert_response :success
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'josep', :password => 'bad password'
    assert_nil session[:ubiquo_user_id]
    assert_response :success
  end

  def test_should_logout
    login_as :josep
    get :destroy
    assert_nil session[:ubiquo_user_id]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'josep', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :login => 'josep', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :josep
    get :destroy
    assert_equal nil, @response.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    ubiquo_users(:josep).remember_me
    @request.cookies["auth_token"] = cookie_for(:josep)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    @request.session[:ubiquo_user_id] = nil #logout
    ubiquo_users(:josep).remember_me
    ubiquo_users(:josep).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:josep)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @request.session[:ubiquo_user_id] = nil #logout
    ubiquo_users(:josep).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert_nil session[:ubiquo_user_id]
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(ubiquo_user)
      auth_token ubiquo_users(ubiquo_user).remember_token
    end
end
