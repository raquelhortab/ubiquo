module UbiquoCategories
  module Extensions
    module Helpers
      
      # Adds a tab for the category set section
      def category_sets_tab(navtab)
        navtab.add_tab do |tab|
          tab.text = I18n.t("ubiquo.categories.categories")
          tab.title = I18n.t("ubiquo.categories.categories")
          tab.highlights_on "ubiquo/category_sets"
          tab.highlights_on "ubiquo/categories"
          tab.link = ubiquo_category_sets_path
        end if ubiquo_config_call(:categories_permit, {:context => :ubiquo_categories})
      end

      # Prepares a collection
      def categories_for_select key
        uhook_categories_for_set category_set(key)
      end

      def render_category_filter(url_for_options, options = {})
        render_filter :links_or_select, url_for_options, {
          :collection => categories_for_select(options[:set]),
          :caption => options[:caption] || t("ubiquo.category_sets.#{options[:set]}"),
          :field => "filter_#{options[:set].to_s.pluralize}",
          :id_field => :name,
          :name_field => :name
        }.merge(options)
      end

      def filter_category_info(params, options = {})
        filter_info :links_or_select, params, {
          :collection => categories_for_select(options[:set]),
          :caption => options[:caption] || t("ubiquo.category_sets.#{options[:set]}"),
          :field => "filter_#{options[:set].to_s.pluralize}",
          :id_field => :name,
          :name_field => :name
        }.merge(options)
      end

      protected

      def category_set(key)
        key = key.to_s.pluralize
        CategorySet.find_by_key(key) ||
          raise(SetNotFoundError, "CategorySet with key '#{key}' not found")
      end

    end
  end
end
