module UbiquoMenus
  module Extensions
    module Ubiquo
      module Widgets
        module MenuWidgetHelper
          # No fancy processing is done, the objective is only have a structured array
          # array acording to the items hierarchy
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

          protected

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
        end
      end
    end
  end
end
