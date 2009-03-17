module UbiquoAccessControl
  module Extensions
    module Helper
      def roles_link(navigator)
        navigator.add_link do |link|
          link.text = I18n.t("ubiquo.auth.roles")
          link.highlights << {:controller => "ubiquo/roles"}
          link.url = ubiquo_roles_path
        end if ubiquo_config_call(:role_permit, {:context => :ubiquo_access_control})
      end
    end
  end
end
