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
      
      def user_permission_fields(form)
        ubiquo_user_roles = form.object.ubiquo_user_roles.map(&:role)
        content_tag("h3", t("ubiquo.auth.roles")) + content_tag("ul", :class => "permissions") do 
          @roles.map do |role|
            content_tag("li") do 
              check_box_tag("ubiquo_user[role_ids][]", role.id, ubiquo_user_roles.include?(role), {:id => "role"+role.id.to_s}) +
                label_tag("role"+role.id.to_s, role.name)
              
            end
          end
        end
      end
    end
  end
end
