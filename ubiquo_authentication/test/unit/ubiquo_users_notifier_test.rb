require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoUsersNotifierTest < ActionMailer::TestCase

  def test_should_send_forgot_password
    ubiquo_user = UbiquoUser.first
    ubiquo_user.reset_password!

    assert ActionMailer::Base.deliveries.empty?
    email = UbiquoUsersNotifier.forgot_password(ubiquo_user, "localhost:3000").deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [ubiquo_user.email], email.to
    assert_match /#{ubiquo_user.password}/ , email.encoded
    assert_match /#{ubiquo_user.login}/ , email.encoded
    assert_match /#{Ubiquo::Settings.get(:app_title)}/ , email.subject
  end

  def test_should_send_confirm_creation
    ubiquo_user = UbiquoUser.first
    ubiquo_user.reset_password!

    assert ActionMailer::Base.deliveries.empty?
    email = UbiquoUsersNotifier.confirm_creation(ubiquo_user, "Welcome message", "localhost:3000").deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [ubiquo_user.email], email.to
    assert_match /#{Regexp.escape(ubiquo_user.password)}/, email.encoded
    assert_match /#{ubiquo_user.login}/, email.encoded
    assert_match /#{Ubiquo::Settings.get(:app_title)}/, email.subject
    assert_match /Welcome message/, email.encoded
  end
end
