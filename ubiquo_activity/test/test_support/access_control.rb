# -*- encoding: utf-8 -*-

class ActiveSupport::TestCase
  def login_as(ubiquo_user)
    return nil if @request.nil?
    ubiquo_user = case ubiquo_user
      when Symbol
        ubiquo_users(ubiquo_user)
      when UbiquoUser
        ubiquo_user
      when nil
        ubiquo_users(:admin)
    end
    #@request.session[:ubiquo] ||= {}
    #@request.session[:ubiquo][:ubiquo_user_id] = ubiquo_user
    @controller.stubs(:current_ubiquo_user).returns(ubiquo_user)
  end

  def login_with_permission(*permission_keys)
    ubiquo_user = ubiquo_users(:eduard)
    if ubiquo_user.respond_to?(:roles)
      ubiquo_user.roles.clear
      role = Role.new(:name => 'test')
      ubiquo_user.roles << role
      permissions_records = permission_keys.map do |key|
        Permission.new(:key => key.to_s, :name => "test #{key}")
      end
      role.permissions << permissions_records
    end
    #@request.session[:ubiquo] ||= {}
    #@request.session[:ubiquo][:ubiquo_user_id] = ubiquo_user
    @controller.stubs(:current_ubiquo_user).returns(ubiquo_user)
  end
end
