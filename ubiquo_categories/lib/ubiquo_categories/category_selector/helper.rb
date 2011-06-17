module UbiquoCategories
  module CategorySelector
    module Helper

      # Renders a category selector in a form
      #   key: CategorySet key (required)
      #   options(optional):
      #     type (:checkbox, :select, :autocomplete)
      #     name (Used as the selector title)
      #     set  (CategorySet to obtains selector categories)
      #     include_blank (defaults to false, true to show a blank option if applicable)
      #     autocomplete_style (:tag, :list)
      #   html_options: options for the fieldset tag (optional)
      def category_selector(object_name, key, options = {}, html_options = {})
        object = options[:object]
        categorize_options = object.class.categorize_options(key)
        raise UbiquoCategories::CategorizationNotFoundError unless categorize_options
        options[:set] ||= category_set(categorize_options[:from] || key.to_s.pluralize)
        categories = uhook_categories_for_set(options[:set], object)
        selector_type = options[:type]
        categorize_size = categorize_options[:size]
        max = Ubiquo::Config.context(:ubiquo_categories).get(:max_categories_simple_selector)
        selector_type ||= case categories.size
          when 0..max
            (categorize_size == :many || categorize_size > 1) ? :checkbox : :select
          else
            :autocomplete
        end
        output = content_tag(:fieldset, html_options) do
          content_tag(:legend, options[:name] || object.class.human_attribute_name(key)) +
            send("category_#{selector_type}_selector",
                 object, object_name, key, categories, options.delete(:set), options)
        end
        output
      end

      protected

      def category_set(key)
        CategorySet.find_by_key(key.to_s) ||
        CategorySet.find_by_key(key.singularize) ||
        raise(SetNotFoundError.new(key))
      end

      def convert_to_tree(set)
        (map = {}).tap do
          set.each do |element|
            (map[element.parent_id] ||= []) << element
          end
        end
      end

      # Creates a set of checkboxes given for the set of given +categories+
      # +options+ can be
      #   css_class:  ul's css class. Defaults to 'check_list'
      #   extra:      string to add at the end of the li
      def checkbox_area(object, object_name, key, categories, options = {})
        options.reverse_merge!({:css_class => 'check_list'})
        content_tag(:ul, :class => options[:css_class]) do
          categories.map do |category|
            content_tag(:li) do
              check_box_tag("#{object_name}[#{key}][]", category.name,
                object.send(key).has_category?(category),
                :id => "#{object_name}_#{key}_#{category.id}") + ' ' +
                label_tag("#{object_name}_#{key}_#{category.id}", category) +
                options[:extra].to_s
            end
          end.join
        end
      end

      def category_checkbox_selector(object, object_name, key, categories, set, options = {})
        tree = convert_to_tree(categories)
        output = ''
        if tree.keys.size == 1
          output = checkbox_area(object, object_name, key, categories)
        else
          tree.each_pair do |parent, children|
            output << checkbox_area(object, object_name, key,
              categories.select{|c| c.id == parent},
              {
                :css_class => 'hierarchical_check_list',
                :extra => checkbox_area(object, object_name, key, children,
                  :css_class => 'children_check_list check_list'
                )
              }
            )
          end
        end

        # hidden field without value is required when you want remove
        # all your selection values
        output << hidden_field_tag("#{object_name}[#{key}][]", '')
        if set.is_editable? && !options[:hide_controls]
          output << new_category_controls("checkbox", object_name, key)
        end
        output
      end

      def category_select_selector(object, object_name, key, categories, set, options = {})
        blank_name = options[:include_blank] if options[:include_blank].kind_of?(String)
        categories_for_select = options[:include_blank] ? [[blank_name, nil]] : []
        categories_for_select += categories.collect { |cat| [cat.name, cat.name] }
        selected_value = object.send(key).name
        output = select_tag(
          "#{object_name}[#{key}][]",
          options_for_select(categories_for_select, :selected => selected_value),
          { :id => "#{object_name}_#{key}_select" }
        )
        if set.is_editable? && !options[:hide_controls]
          output << new_category_controls("select", object_name, key)
        end
        output
      end

      def category_autocomplete_selector(object, object_name, key, categories, set, options = {})
        url_params = { :category_set_id => set.id, :format => :js }
        autocomplete_options = {
          :url => ubiquo_category_set_categories_path(url_params),
          :current_values => Array(object.send(key)).to_json(:only => [:id, :name]),          
          :style => options[:autocomplete_style] || "tag"
        }

        obj_size = object.class.instance_variable_get(:@categorized_with_options)[key][:size] || :many

        size = (obj_size == :many ? 'null' : obj_size.to_i)

        js_code =<<-JS
          document.observe('dom:loaded', function() {
            var autocomplete = new AutoCompleteSelector(
              '#{autocomplete_options[:url]}',
              '#{object_name}',
              '#{key}',
              #{autocomplete_options[:current_values]},
              '#{autocomplete_options[:style]}',
              #{set.is_editable?},
              #{size}
            )
          });
        JS
        javascript_tag(js_code) +
          text_field_tag("#{object_name}[#{key}][]", "",
                         :id => "#{object_name}_#{key}_autocomplete")
      end

      def new_category_controls(type, object_name, key)
        content_tag(:div, :class => "new_category_controls") do
          link_to(t("ubiquo.category_selector.new_element"), '#',
                  :id => "link_new__#{type}__#{object_name}__#{key}",
                  :class => "category_selector_new") +
          content_tag(:div, :class => "add_new_category", :style => "display:none") do
            text_field_tag("new_#{object_name}_#{key}", "", :id => "new_#{object_name}_#{key}") +
            link_to(t("ubiquo.category_selector.add_element"), "", :class => "add_new_category_link")
          end
        end
      end
    end
  end
end


# Helper method for form builders
module ActionView
  module Helpers
    class FormBuilder
      def category_selector(key, options = {}, html_options = {})
        options = options.merge(:object => @object)
        @template.category_selector(@object_name, key, options, html_options)
      end
    end
  end
end
