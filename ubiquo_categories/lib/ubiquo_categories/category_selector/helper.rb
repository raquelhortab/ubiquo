module UbiquoCategories
  module CategorySelector
    module Helper
      # 
      # options(optional): type (checkbox, select, autocomplete)
      # html_options(optional)
      def category_selector(object_name, key, options = {}, html_options = {})
        object = options[:object]
        key = key.to_s.pluralize
        categories = category_set(key).categories
        selector_type = options[:type]
        selector_type ||= case categories.size
          when 0..6
            object.class.categorize_options(key)[:size] > 1 ? :checkbox : :select
          else
            :autocomplete
        end
        send("category_#{selector_type}_selector", object, object_name, key, categories)
      end
      
      protected
      
      def category_set(key)
        CategorySet.find_by_key(key) || raise(SetNotFoundError, "CategorySet with key '#{key}' not found")
      end
      
      def category_checkbox_selector(object, object_name, key, categories)
        output = ""
        categories.each do |category|
          output << check_box_tag("#{object_name}[#{key}][]", category.name, object.send(key).has_category?(category),
                                  :id => "#{object_name}_#{key}_#{category.id}")
          output << label_tag("#{object_name}_#{key}_#{category.id}", category)
        end
        output
      end
      
      def category_select_selector(object, object_name, key, categories)
        output = label(object_name, key)
        output << select(object_name, 
          key, 
          options_for_select(categories.collect { |cat| [cat.name, cat.name]},
                             :selected => object.send(key, true).name),
          { :include_blank => true }
        )
      end
      
      def category_autocomplete_selector
        "autocomplete"
      end
    end
  end
end


# Helper method for form builders
module ActionView
  module Helpers
    class FormBuilder
      def category_selector(key, options = {}, html_options = {})
        @template.category_selector(@object_name, key, options.merge(:object => @object), html_options)
      end
    end
  end
end
