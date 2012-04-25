module UbiquoMenus
  module Extensions
    module MenuSelectionResolver

      def menu_item_selected?(item, url = request.path)
        begin
          return false unless item.is_active && item.is_linkable
          case item.link
          when Page
            page_selected?(item.link, url)
          when String
            url_selected?(item.link, url)
          end
        rescue Exception => e
          Rails.logger.warn("Application crash computing menu_item selection:\n #{e.backtrace}")
          false
        end
      end

      protected

      def page_selected?(page, url)
        if url_for_page(page) == "/"
          url_for_page(page) == url
        else
          url.include?(url_for_page(page)) || url.include?(url_for_page(page.published))
        end
      end

      def url_selected?(item_url, current_url)
        if root_url?(item_url)
          root_url?(current_url)
        else
          current_url.include?(item_url)
        end
      end

      def root_url?(url)
        url.blank? || url == '/'
      end
    end
  end
end
