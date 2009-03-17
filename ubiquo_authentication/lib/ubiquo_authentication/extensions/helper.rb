module UbiquoAuthentication
  module Extensions
    module Helper
      def ubiquo_users_link(navigator)
        navigator.add_link do |link|
          link.text = I18n.t("ubiquo.auth.users")
          link.highlights << {:controller => "ubiquo/ubiquo_users"}
          link.highlights << {:controller => "ubiquo/permissions"}
          link.url = ubiquo_ubiquo_users_path
        end if ubiquo_config_call(:user_navigator_permission, {:context => :ubiquo_authentication})
      end
      
      def logout_link(navigator)
        navigator.add_link(:method => :delete) do |link|
          link.text = I18n.t("ubiquo.auth.logout")
          link.url = ubiquo_logout_path
        end
      end
      
      def ubiquo_user_name_link(navigator)
        navigator.add_link do |link|
          link.text = current_ubiquo_user.login
          link.disabled = true
          link.class = "ubiquo_user"
        end
      end
    end
  end
end
