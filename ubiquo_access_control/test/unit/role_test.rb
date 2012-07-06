require File.dirname(__FILE__) + "/../test_helper.rb"

class RoleTest < ActiveSupport::TestCase

  def test_should_create_role
    assert_difference 'Role.count' do
      role = create_role
      assert !role.new_record?, "#{role.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Role.count' do
      role = create_role(:name => nil)
      assert role.errors[:name]
    end
  end

  def test_destroy_user_dependencies
    role=nil
    assert_difference 'Role.count' do
      assert_difference 'UbiquoUserRole.count' do
        role = create_role
        UbiquoUser.find(:first).roles << role
      end
    end
    assert_difference 'Role.count', -1 do
      assert_difference 'UbiquoUserRole.count', -1 do
        role.destroy
      end
    end
  end

  def test_destroy_permission_dependencies
    role=nil
    assert_difference 'Role.count' do
      assert_difference 'RolePermission.count' do
        role = create_role
        role.permissions << permissions(:permission_1)
      end
    end
    assert_difference 'Role.count', -1 do
      assert_difference 'RolePermission.count', -1 do
        role.destroy
      end
    end
  end

  protected

  def create_role(options = {})
    Role.create({ :name => "New role" }.merge(options))
  end

end
