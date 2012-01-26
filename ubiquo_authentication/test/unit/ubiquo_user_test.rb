require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoUserTest < ActiveSupport::TestCase
  fixtures :ubiquo_users

  def test_should_create_ubiquo_user
    assert_difference 'UbiquoUser.count' do
      ubiquo_user = create_ubiquo_user
      assert !ubiquo_user.new_record?, "#{ubiquo_user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_be_able_to_create_first_user_when_no_users
    UbiquoUser.destroy_all
    assert_difference 'UbiquoUser.count' do
      ubiquo_user = UbiquoUser.create_first('mylogin','mypassword')
      assert ubiquo_user.is_superadmin
    end
  end

  def test_should_not_be_able_to_create_first_user_when_other_users
    create_ubiquo_user
    assert_no_difference 'UbiquoUser.count' do
      assert_nil UbiquoUser.create_first('mylogin','mypassword')
    end
  end

  def test_should_not_be_able_to_create_first_user_in_production
    Rails.env.stubs(:production?).returns(true)
    UbiquoUser.destroy_all
    assert_no_difference 'UbiquoUser.count' do
      assert_nil UbiquoUser.create_first('mylogin','mypassword')
    end
  end

  def test_should_require_name
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:name => nil)
      assert u.errors[:name]
    end
  end

  def test_should_require_surname
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:surname => nil)
      assert u.errors[:surname].any?
    end
  end

  def test_should_require_login
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:login => nil)
      assert u.errors[:login].any?
    end
  end

  def test_should_require_email
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:email => nil)
      assert u.errors[:email].any?
    end
  end

  def test_should_require_unique_email
    assert_difference 'UbiquoUser.count', 1 do
      email = "unique.mail@mail.com"
      u = create_ubiquo_user(:email => email)
      assert !u.new_record?

      u = create_ubiquo_user(:email => email)
      assert u.errors[:email].any?

      u = create_ubiquo_user(:email => email.upcase)
      assert u.errors[:email].any?
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
        assert u.errors[:email].any?
      end
    end
  end

  def test_should_require_password
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:password => nil)
      assert u.errors[:password].any?
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:password_confirmation => nil)
      assert u.errors[:password_confirmation].any?
    end
  end

  def test_should_require_valid_password_confirmation
    assert_no_difference 'UbiquoUser.count' do
      u = create_ubiquo_user(:password => "pass", :password_confirmation => "wrong pass")
      assert u.errors[:password].any?
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

  def test_should_filter_by_admin
    admin_ubiquo_users = [ubiquo_users(:admin), ubiquo_users(:superadmin)]
    non_admin_ubiquo_users = [ubiquo_users(:josep), ubiquo_users(:inactive), ubiquo_users(:eduard)]
    assert_equal admin_ubiquo_users.to_set, UbiquoUser.filtered_search({"filter_admin" => "true"}).to_set
    assert_equal non_admin_ubiquo_users.to_set, UbiquoUser.filtered_search({"filter_admin" => "false"}).to_set
  end

  def test_should_filter_by_active
    active_ubiquo_users = [ubiquo_users(:admin), ubiquo_users(:josep), ubiquo_users(:eduard), ubiquo_users(:superadmin)]
    non_active_ubiquo_users = [ubiquo_users(:inactive)]

    assert_equal active_ubiquo_users.to_set, UbiquoUser.filtered_search({"filter_active" => "true"}).to_set
    assert_equal non_active_ubiquo_users.to_set, UbiquoUser.filtered_search({"filter_active" => "false"}).to_set
  end

  def test_should_filter_by_name
    users = [
      create_ubiquo_user(:login => 'log1', :email => '1@prova.com', :name => "find me"),
      create_ubiquo_user(:login => 'log2', :email => '2@prova.com', :name => "FiNdMe"),
      create_ubiquo_user(:login => 'log3', :email => '3@prova.com', :name => "hide me"),
    ]
    assert_equal_set users[0..1], UbiquoUser.filtered_search({"filter_text" => "find"})
  end

  def test_should_filter_by_surname
    users = [
      create_ubiquo_user(:login => 'log1', :email => '1@prova.com', :surname => "find me"),
      create_ubiquo_user(:login => 'log2', :email => '2@prova.com', :surname => "FiNdMe"),
      create_ubiquo_user(:login => 'log3', :email => '3@prova.com', :surname => "hide me"),
    ]
    assert_equal_set users[0..1], UbiquoUser.filtered_search({"filter_text" => "find"})
  end

  def test_should_filter_by_login
    users = [
      create_ubiquo_user(:login => 'findme',      :email => '1@prova.com'),
      create_ubiquo_user(:login => 'findmeagain', :email => '2@prova.com'),
      create_ubiquo_user(:login => 'hideme',      :email => '3@prova.com'),
    ]
    assert_equal_set users[0..1], UbiquoUser.filtered_search({"filter_text" => "find"})
  end

  def test_should_generate_random_password
    password = ubiquo_users(:josep).reset_password!
    assert_equal ubiquo_users(:josep), UbiquoUser.authenticate('josep', password)
  end

  protected

  def create_ubiquo_user(options = {})
    UbiquoUser.create({
        :name => "name",
        :surname => "surname",
        :login => 'quire',
        :email => "quire@quire.com",
        :password => 'quire',
        :password_confirmation => 'quire'
      }.merge(options))
  end

end
