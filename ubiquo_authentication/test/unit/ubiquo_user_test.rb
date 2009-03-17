require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoUserTest < ActiveSupport::TestCase
  use_ubiquo_fixtures
  
  # fixtures :ubiquo_users
  def test_should_create_ubiquo_user
    assert_difference 'UbiquoUser.count' do
      ubiquo_user = create_ubiquo_user
      assert !ubiquo_user.new_record?, "#{ubiquo_user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:login => nil)
      assert u.errors.on(:login)
    end
  end
  
  def test_should_require_email
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:email => nil)
      assert u.errors.on(:email)
    end
  end
  def test_should_require_unique_email
    assert_difference 'UbiquoUser.count', 1 do
      u = create_ubiquo_user(:email => "unique.mail@mail.com")
      assert !u.new_record?
      
      u = create_ubiquo_user(:email => "unique.mail@mail.com")
      assert u.errors.on(:email)
    end
  end
  
  def test_should_require_valid_email
    valid_mails = ["quire@quire.com", "qui.re@qui.re.com", "quire#spam@quire.com" ]
    not_valid_mails = ["qui re@quire.com", "quire quire.com", "quire.com", "quire@quire@quire.com", "quire@quire"]
    assert_difference 'UbiquoUser.count', valid_mails.size do
      valid_mails.each do |mail|
        u = create_ubiquo_user(:email => mail, :login => mail)
        assert !u.new_record?, mail
      end
    end
    assert_no_difference 'UbiquoUser.count' do
      not_valid_mails.each do |mail|
        u = create_ubiquo_user(:email => mail)
        assert u.errors.on(:email), mail
      end
    end
  end

  def test_should_require_password
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_valid_password_confirmation
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:password => "pass", :password_confirmation => "wrong pass")
      assert u.errors.on(:password)
    end
  end

  def test_should_authenticate_ubiquo_user
    assert_equal ubiquo_users(:josep), UbiquoUser.authenticate('josep', 'test')
  end

  def test_should_reset_password
    ubiquo_users(:josep).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal ubiquo_users(:josep), UbiquoUser.authenticate('josep', 'new password')
  end

  def test_should_not_rehash_password
    ubiquo_users(:josep).update_attributes(:login => 'josep2')
    assert_equal ubiquo_users(:josep), UbiquoUser.authenticate('josep2', 'test')
  end

  def test_should_set_remember_token
    ubiquo_users(:josep).remember_me
    assert_not_nil ubiquo_users(:josep).remember_token
    assert_not_nil ubiquo_users(:josep).remember_token_expires_at
  end

  def test_remember_token_duration
    assert !ubiquo_users(:josep).remember_token?
    ubiquo_users(:josep).remember_me
    assert ubiquo_users(:josep).remember_token?
    ubiquo_users(:josep).remember_me_for -1.week
    assert !ubiquo_users(:josep).remember_token?
  end

  def test_should_unset_remember_token
    ubiquo_users(:josep).remember_me
    assert_not_nil ubiquo_users(:josep).remember_token
    ubiquo_users(:josep).forget_me
    assert_nil ubiquo_users(:josep).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    ubiquo_users(:josep).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil ubiquo_users(:josep).remember_token
    assert_not_nil ubiquo_users(:josep).remember_token_expires_at
    assert ubiquo_users(:josep).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    ubiquo_users(:josep).remember_me_until time
    assert_not_nil ubiquo_users(:josep).remember_token
    assert_not_nil ubiquo_users(:josep).remember_token_expires_at
    assert_equal ubiquo_users(:josep).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = Ubiquo::Config.context(:ubiquo_authentication).get(:remember_time).from_now.utc
    ubiquo_users(:josep).remember_me
    after = Ubiquo::Config.context(:ubiquo_authentication).get(:remember_time).from_now.utc
    assert_not_nil ubiquo_users(:josep).remember_token
    assert_not_nil ubiquo_users(:josep).remember_token_expires_at
    assert ubiquo_users(:josep).remember_token_expires_at.between?(before, after)
  end

  # Permissions tests:

  def test_should_add_simple_role
    u=ubiquo_users(:eduard)
    r=roles(:role_1)
    p=permissions(:permission_1)
    
    r.add_permission(p)

    assert !u.has_permission?(p)
    assert r.has_permission?(p)
    assert_difference "UbiquoUserRole.count" do
      assert u.add_role(r)
    end
    assert u.has_permission?(p)
  end

  def test_should_remove_simple_role
    u=ubiquo_users(:josep)
    r=roles(:role_1)
    p=permissions(:permission_1)
    
    r.add_permission(p)
    u.add_role(r)

    assert u.has_permission?(p)
    assert_difference "UbiquoUserRole.count",-1 do
      assert u.remove_role(r)
    end
    assert !u.has_permission?(p)
  end

  def test_should_be_admin
    ubiquo_user = create_ubiquo_user(:is_admin => true)
    Permission.find(:all).each do |permission|
      assert ubiquo_user.has_permission?(permission)
    end
  end

  def test_should_filter_by_admin
    admin_ubiquo_users = [ubiquo_users(:admin)]
    non_admin_ubiquo_users = [ubiquo_users(:josep), ubiquo_users(:inactive), ubiquo_users(:eduard)]
    assert UbiquoUser.filtered_search({:filter_admin => true}).to_set == admin_ubiquo_users.to_set
    assert UbiquoUser.filtered_search({:filter_admin => false}).to_set == non_admin_ubiquo_users.to_set      
  end
  
  def test_should_generate_random_password
    password = ubiquo_users(:josep).reset_password!
    assert_equal ubiquo_users(:josep), UbiquoUser.authenticate('josep', password)
  end
  
  protected
  
  def create_ubiquo_user(options = {})
    UbiquoUser.create({:login => 'quire', :email => "quire@quire.com", :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end

end
