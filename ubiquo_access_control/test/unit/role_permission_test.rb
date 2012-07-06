require File.dirname(__FILE__) + "/../test_helper.rb"

class RolePermissionTest < ActiveSupport::TestCase

  def test_should_create_role_permission
    assert_difference 'RolePermission.count' do
      rp = create_role_permission
      assert !rp.new_record?, "#{rp.errors.full_messages.to_sentence}"
    end
  end

  protected
  def create_role_permission(options = {})
    RolePermission.create({ :role => Role.find(:first, :offset=>1), :permission=>Permission.find(:first) }.merge(options))
  end

end
