module UbiquoCategories
  module Connectors
    class I18n < Base

      def self.validate_requirements
        validate_i18n_requirements(::Category)
      end

      def self.unload!
        ::Category.untranslatable
      end

      module Category

        def self.included(klass)
          klass.send(:extend, ClassMethods)
          klass.send(:translatable, :name, :description)
#          klass.send(:attr_accessible, :content_id, :locale)
          I18n.register_uhooks klass, ClassMethods
        end

        module ClassMethods

          # Returns a condition to return categories using their +identifiers+
          def uhook_category_identifier_condition identifiers, association
            ["#{::Category.alias_for_association(association)}.content_id IN (?)", identifiers]
          end

          def uhook_join_category_table_in_category_conditions_for_sql
            true
          end

          # Applies any required extra scope to the filtered_search method
          def uhook_filtered_search filters = {}
            create_scopes(filters) do |filter, value|
              case filter
              when :locale
                {:conditions => {:locale => value}}
              end
            end
          end

          # Initializes a new category with the given +name+ and +options+
          def uhook_new_from_name name, options = {}
            ::Category.new(
              :name => name,
              :locale => (options[:locale] || :any).to_s,
              :parent_id => options[:parent_id]
            )
          end
        end

      end

      module CategorySet

        def self.included(klass)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
        end

        module InstanceMethods
          # Returns an identifier value for a given +category_name+ in this set
          def uhook_category_identifier_for_name category_name
            self.select_fittest(category_name).content_id rescue 0
          end

          # Returns the fittest category in the requested locale
          def uhook_select_fittest category, options = {}
            options[:locale] ? (category.in_locale(options[:locale]) || category) : category
          end
        end

      end

      module UbiquoCategoriesController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          klass.send(:helper, Helper)
          I18n.register_uhooks klass, InstanceMethods
        end

        module Helper

          def uhook_category_filters(filter_set)
            filter_set.locale
          end

          # Returns content to show in the sidebar when editing a category
          def uhook_edit_category_sidebar category
            show_translations(category, :hide_preview_link => true)
          end

          # Returns content to show in the sidebar when creating a category
          def uhook_new_category_sidebar category
            show_translations(category, :hide_preview_link => true)
          end

          # Returns the available actions links for a given category
          def uhook_category_index_actions category_set, category
            actions = []
            if category.in_locale?(current_locale)
              actions << category_view_link(category, category_set)
            end

            if category.in_locale?(current_locale)
              actions << category_edit_link(category, category_set)
            end

            unless category.in_locale?(current_locale)
              actions << category_translate_link(category, category_set)
            end

            actions << category_remove_link(category, category_set)

            if category.in_locale?(current_locale, :skip_any => true) && !category.translations.empty?
              actions << category_remove_translation_link(category, category_set)
            end

            actions
          end

          # Returns any necessary extra code to be inserted in the category form
          def uhook_category_form form
            (form.hidden_field :content_id) + (hidden_field_tag(:from, params[:from]))
          end

          # Returns the locale information of this category
          def uhook_category_partial category
            locale = ::Locale.find_by_iso_code(category.locale)
            content_tag(:dt, ::Category.human_attribute_name("locale") + ':') +
            content_tag(:dd, (locale.native_name.capitalize.html_safe rescue t('ubiquo.category.any')))
          end

          def category_translate_link(category, category_set)
            link_to(
              t("ubiquo.translate"),
              ubiquo.new_category_set_category_path(
                :from => category.content_id
              )
            )
          end

          def category_remove_link(category, category_set)
            link_to(t("ubiquo.remove"),
              ubiquo.category_set_category_path(category_set, category, :destroy_content => true),
              :data => {:confirm => t("ubiquo.category.index.confirm_removal")}, :method => :delete, :class => 'btn-delete'
            )
          end

          def category_remove_translation_link(category, category_set)
            link_to(t("ubiquo.remove_translation"), [ubiquo, category_set, category],
              :data => {:confirm => t("ubiquo.category.index.confirm_removal")}, :method => :delete
            )
          end
        end

        module InstanceMethods

          # Returns a hash with extra filters to apply
          def uhook_index_filters
            {:locale => params[:filter_locale]}
          end

          # Returns a subject that will have applied the index filters
          # (e.g. a class, with maybe some scopes applied)
          def uhook_index_search_subject
            ::Category.locale(current_locale, :all)
          end

          # Initializes a new instance of category.
          def uhook_new_category
            ::Category.translate(params[:from], current_locale, :copy_all => true)
          end

          # Performs any required action on category when in show
          def uhook_show_category category
            unless category.in_locale?(current_locale)
              redirect_to(ubiquo.category_set_categories_url)
              false
            end
          end

          # Performs any required action on category when in edit
          def uhook_edit_category category
            unless category.in_locale?(current_locale)
              redirect_to(ubiquo.category_set_categories_url)
              false
            end
          end

          # Creates a new instance of category.
          def uhook_create_category
            category = ::Category.new(params[:category])
            category.locale = current_locale
            category
          end

          # Destroys a category instance. returns a success boolean
          def uhook_destroy_category(category)
            destroyed = false
            if params[:destroy_content]
              destroyed = category.destroy_content
            else
              destroyed = category.destroy
            end
            destroyed
          end
        end
      end

      module Migration

        def self.included(klass)
          klass.send(:extend, ClassMethods)
          I18n.register_uhooks klass, ClassMethods
        end

        module ClassMethods
          def uhook_create_categories_table
            create_table :categories, :translatable => true do |t|
              yield t
            end
          end

          def uhook_create_category_relations_table
            create_table :category_relations do |t|
              yield t
            end
          end
        end
      end

      module ActiveRecord
        module Base

          def self.included(klass)
            klass.send(:extend, ClassMethods)
            I18n.register_uhooks klass, ClassMethods
          end

          module ClassMethods
            # Adds the +categories+ to the +set+ and returns the categories that
            # will be effectively related to +object+
            def uhook_assign_to_set set, categories, object
              if object.class.is_translatable?
                locale = object.locale || Locale.current
              end
              categories_options = {}
              categories_options.merge!(:locale => locale)

              set.categories << [categories, categories_options]
              categories = Array(categories).reject(&:blank?)
              categories.map do |c|
                set.select_fittest(c, :locale => locale)
              end.uniq.compact
            end

            # Defines the relation as translation_shared if is a translatable class
            def uhook_categorized_with field, options
              association_name = field.to_s.pluralize.to_sym
              if self.is_translatable?
                share_translations_for association_name
                # overwrite the aliased methods since now should use the i18n methods
                if field.to_s != association_name
                  alias_method field, association_name
                  alias_method "#{field}=", "#{association_name}="
                end
              end
            end
          end

        end
      end

      module UbiquoHelpers
        module Helper
          # Returns a the applicable categories for +set+
          # +context+ can be a related object that restricts the possible categories
          def uhook_categories_for_set set, object = nil
            locale = if object && object.class.is_translatable?
              object.locale
            else
              current_locale
            end
            set.categories.locale(locale, :all)
          end
        end
      end

      def self.prepare_mocks
        add_mock_helper_stubs({
          :show_translations => '', :current_locale => Locale.current,
          :content_tag => '', :hidden_field_tag => '', :locale => Category,
          :category_view_link => '', :category_edit_link => '', :category_remove_link => ''
        })
      end

    end
  end
end
