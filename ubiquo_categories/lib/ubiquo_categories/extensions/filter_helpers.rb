require 'ubiquo_categories/extensions/filter_helpers/category_filter'

module UbiquoCategories
  module Extensions
    module FilterHelpers
    end
  end
end

Ubiquo::Extensions::FilterHelpers.send(:include, UbiquoCategories::Extensions::FilterHelpers)
