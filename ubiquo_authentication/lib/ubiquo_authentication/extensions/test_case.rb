module UbiquoAuthentication
  module Extensions
    module TestCase
      
      def login_as(ubiquo_user = nil)
        return nil if @request.nil?
        ubiquo_user = case ubiquo_user
                      when Symbol
                        ubiquo_users(ubiquo_user).id
                      when UbiquoUser
                        ubiquo_user.id
                      when nil
                        ubiquo_users(:admin).id
                      end
        @request.session[:ubiquo_user_id] = ubiquo_user
      end
      
    end
  end
end
