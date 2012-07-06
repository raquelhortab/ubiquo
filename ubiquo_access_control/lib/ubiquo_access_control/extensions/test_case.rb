module UbiquoAccessControl
  module Extensions
    module TestCase
      # Test helper. will log a user with the given permission keys
      def login_with_permission(*permission_keys)
        ubiquo_user = ubiquo_users(:eduard)
        ubiquo_user.roles.clear
        role = Role.new(:name => 'test')
        ubiquo_user.roles << role
        permissions_records = permission_keys.map do |key|
          Permission.new(:key => key.to_s, :name => "test #{key}")
        end
        role.permissions << permissions_records
        @request.session[:ubiquo] ||= {}
        @request.session[:ubiquo][:ubiquo_user_id] = ubiquo_user
      end

      # Given an ubiquo user or its fixture identifier, login as him
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
        @request.session[:ubiquo] ||= {}
        @request.session[:ubiquo][:ubiquo_user_id] = ubiquo_user.id
      end
    end
  end
end
