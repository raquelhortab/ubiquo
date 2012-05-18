module UbiquoMenus
  module Extensions
    module Ubiquo
      module Helper
        # Button to submit the new form and continue editing the object
        def create_and_continue_button(f, text = nil, options = {} )
          options = options.reverse_merge(:class => 'bt-save-continue',
            :id => 'menu_save_and_continue',
            :name => 'save_and_continue').
            reverse_merge( f.respond_to?(:default_tag_options) ? f.default_tag_options[:create_button] : {} )

          text = text || t('ubiquo.save_and_continue')
          f.submit text, options
        end

        def menus_tab(tabnav)
          tabnav.add_tab do |tab|
            tab.text = I18n.t("ubiquo.menus.menu_tab")
            tab.title = I18n.t("ubiquo.menus.menu_tab_title")
            tab.highlights_on({:controller => "ubiquo/menus"})
            tab.highlights_on({:controller => "ubiquo/menu_items"})
            tab.link = link_to_default_menu || ubiquo.menus_path
          end if ubiquo_config_call :menus_permit, {:context => :ubiquo_menus}
        end

        def link_to_default_menu
          if ::Ubiquo::Settings[:ubiquo_menus].option_exists?(:default_menu)
            default_menu = Ubiquo::Settings[:ubiquo_menus][:default_menu]
            default_menu = case default_menu
            when Integer
              Menu.find(default_menu)
            when String
              Menu.where(:key => default_menu)
            else
              default_menu
            end
            ubiquo.edit_menu_path(default_menu)
          end
        end
      end
    end
  end
end
