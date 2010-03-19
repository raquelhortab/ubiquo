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
        end if ubiquo_config_call(:assets_permit, {:context => :ubiquo_media})
      end

    end
  end
end
