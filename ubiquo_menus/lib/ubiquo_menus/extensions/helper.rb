module UbiquoMenus
  module Extensions
    module Helper
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

      def menu_item item, options = {}
        print_children = options.has_key?(:print_children) ? options[:print_children] : true
        menu_class = menu_item_selected?(item[:item]) ? "active" : ""
        content_tag(:li, :class => menu_class) do
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
                               item[:children].map { |children| menu_item(children).html_safe }.join.html_safe,
                              :id => item[:id],
                              :class => "menu_item-#{item[:klass]}").html_safe
          else
            m.html_safe
          end
        end.html_safe
      end

      protected

      def trim_current_locale(url)
        groups = url.split("/")
        groups.slice!(groups.index(I18n.locale.to_s)) if groups.index(I18n.locale.to_s)
        groups.join("/").blank? ? "/" : groups.join("/")
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
