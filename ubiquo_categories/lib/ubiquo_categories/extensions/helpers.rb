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

      # prepares a collection
      def categories_for_select key
        category_set(key).categories.locale(current_locale, :ALL)
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
        CategorySet.find_by_key(key.to_s.pluralize) || raise(SetNotFoundError, "CategorySet with key '#{key.to_s.pluralize}' not found")
      end

    end
  end
end
