module UbiquoMenus
  module Extensions
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

      # FIXME TODO Ubiquo_core needs to adapt this call to menus_tab
      def sitemap_tab(tabnav)
        menus_tab(tabnav)
      end
      def menus_tab(tabnav)
        tabnav.add_tab do |tab|
          tab.text = I18n.t("ubiquo.menus.menu_tab")
          tab.title = I18n.t("ubiquo.menus.menu_tab_title")
          tab.highlights_on({:controller => "ubiquo/menus"})
          tab.highlights_on({:controller => "ubiquo/menu_items"})
          #We set the link to the given menu if specified
          default_menu_id = Ubiquo::Config.context(:ubiquo_menus).get(:default_menu) rescue nil
          link = ubiquo.menus_path
          if default_menu_id && default_menu = Menu.find(default_menu_id)
            link = ubiquo_menu_menu_items_path(default_menu_id)
          end
          tab.link = link
        end if ubiquo_config_call :menus_permit, {:context => :ubiquo_menus}
      end

      def process_menu_items menu_items, options = {}
        hash_model = []
        menu_items.each do |menu_item|
          if menu_item.is_active
            caption = menu_item.caption
            id = menu_item.id
            klass = 'menu_item'
            link = "javascript:void(0)"
            if menu_item.is_linkable?
              link = menu_item.link.is_a?(Page) ? url_for_page(menu_item.link) : menu_item.url
            end
            children = process_menu_items(menu_item.children)
            hash_model << {:caption => caption,
                            :id => id,
                            :klass => klass,
                            :url => link,
                            :children => children,
                            :description => menu_item.description,
                            :selected => menu_item_selected?(menu_item)}
          end
        end
        hash_model
      end

      def print_menu menu, options = {}
        unless menu.is_a?(Menu)
          menu = uhook_find_by_key(menu)
        end
        @options = options
        if menu.present?
          @hash_model = menu_items_array_for(menu)
          partial_path = "/shared/menus/standard_menu"
          if File.exists?(Rails.root.join("app", "views", "shared", "menus", "_#{menu.key}_menu.html.erb"))
            partial_path = "/shared/menus/#{menu.key}_menu"
          end
          render :partial => partial_path,
                  :locals => { :menu => menu,
                                :options => options,
                                :hash_model => @hash_model }
        end
      end

      def trim_current_locale(url)
        groups = url.split("/")
        groups.slice!(groups.index(I18n.locale.to_s)) if groups.index(I18n.locale.to_s)
        groups.join("/").blank? ? "/" : groups.join("/")
      end

      def menu_item_selected?(item, url = request.path)
        begin
          item.is_active && item.is_linkable &&
          (item.link.is_a?(Page) ? page_selected?(item.link, url) : item.url == "/" || item.url == "" ? url == "/" || url == "" : url.include?(item.url))
        rescue Exception => e
          false
        end
      end

      def page_selected?(page, url)
        if url_for_page(page) == "/"
          url_for_page(page) == url
        else
          url.include?(url_for_page(page)) || url.include?(url_for_page(page.published))
        end
      end

      def menu_item item, options = {}
        print_children = options.has_key?(:print_children) ? options[:print_children] : true
        menu_class = item[:item][:selected] ? "active" : ""
        menu_element = content_tag(:li, :class => menu_class) do
          link = "javascript:void(0)"
          if item[:item].is_linkable?
            link = item[:item].link.is_a?(Page) ? url_for_page(item[:item].link) : item[:item].url
          end
          m = link_to(item[:item][:caption],
                      link,
                      {:id => "menu_item_#{item[:item].id}"}) +
              content_tag(:span, item[:display_descriptions] ? item[:item][:description]: "")
          if item[:children].present? && print_children
            m += content_tag(:ul,
                               item[:children].map { |children| menu_item(children) }.join,
                              :id => item[:id],
                              :class => "menu_item-#{item[:klass]}")
          else
            m
          end
        end
      end

      def process_menu_items_structure menu_items, options = {}
        hash_model = []
        menu_items.each do |menu_item|
          if menu_item.is_active
            caption = menu_item.caption
            children = process_menu_items(menu_item.children)
            hash_model << {:caption => caption,
                            :children => children,
                            :description => menu_item.description}
          end
        end
        hash_model
      end

      def print_menu_structure menu_or_key
        menu = menu_or_key
        menu = uhook_find_by_key(menu_or_key) if menu_or_key.is_a?(String)
        if menu.present?
          @hash_model = []
          @hash_model += process_menu_items_structure(menu.menu_items.roots)
          content_tag(:ul) do
            @hash_model.map do |root|
              menu_item_structure(root).html_safe
            end.join.html_safe
          end.html_safe
        end
      end

      def menu_item_structure item
        menu_element = content_tag(:li, :style => "margin-left:10px") do
          item[:caption].html_safe +
          if item[:children].present?
            content_tag(:ul, menu_element) do
              item[:children].map { |children| menu_item_structure(children).html_safe }.join.html_safe
            end.html_safe
          else
            ""
          end
        end.html_safe
      end

      def menu_items_array_for(menu)
        menu_items_array = []
        menu_items = get_menu_items(menu)
        uhook_build_menu_items_array(menu_items_array, menu_items)
        menu_items_array
      end

      def get_menu_items(menu)
        uhook_get_menu_items(menu)
      end
    end
  end
end
