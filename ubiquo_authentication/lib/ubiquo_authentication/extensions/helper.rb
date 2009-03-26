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
      
      def superadmin_home_tab(tabnav)
        tabnav.add_tab do |tab|
          tab.text =  I18n.t("ubiquo.auth.superadmin_home")
          tab.title =  I18n.t("ubiquo.auth.superadmin_home_title")
          tab.highlights_on({:controller => "ubiquo/superadmin_homes"})
          tab.link = ubiquo_superadmin_home_path  
        end
      end
      
      def toggle_superadmin_mode_link(navigator)
        return unless current_ubiquo_user.is_superadmin?
        if superadmin_mode?
          navigator.add_link(:method => :delete) do |link|
            link.text = t("ubiquo.auth.back_from_superadmin_mode")
            link.url = ubiquo_superadmin_mode_path
          end
        else
          navigator.add_link(:method => :post) do |link|
            link.text = t("ubiquo.auth.go_to_superadmin_mode")
            link.url = ubiquo_superadmin_mode_path
          end
        end
      end
      
      def superadmin_mode?
        session[:superadmin_mode]==true
      end
    end
  end
end
