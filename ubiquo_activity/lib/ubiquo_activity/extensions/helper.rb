module UbiquoActivity
  module Extensions
    module Helper
      # Adds a "Activity Info" tab
      def activity_info_tab(tabnav)
        if ubiquo_config_call(:activity_info_permit, { :context => :ubiquo_activity })
          tabnav.add_tab do |tab|
            tab.text = I18n.t("ubiquo.activity_info.tab_name")
            tab.title = I18n.t("ubiquo.activity_info.tab_title")
            tab.highlights_on({:controller => "ubiquo/activity_infos"})
            tab.link = ubiquo_activity_infos_path  
          end
        end
      end
    end
  end
end
