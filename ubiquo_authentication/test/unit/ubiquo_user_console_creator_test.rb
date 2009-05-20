require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoUserConsoleCreatorTest < ActiveSupport::TestCase

  # This ensures we don't miss the rake ubiquo:create_user task when updating the UbiquoUser required fields
  def test_should_be_able_to_create_a_user
    UbiquoUser.destroy_all
    assert_difference 'UbiquoUser.count' do
      ubiquo_user =  UbiquoAuthentication::UbiquoUserConsoleCreator.create!(
                       :login => 'login',
                       :password => 'password',
                       :password_confirmation => 'password',
                       :name => 'myname',
                       :surname => 'mysurname1 mysurname2',
                       :email => 'myemail@test.com',
                       :is_active => true,
                       :is_admin => true,
                       :is_superadmin => true)
      assert !ubiquo_user.new_record?, "#{ubiquo_user.errors.full_messages.to_sentence}"
    end
  end
  
end
