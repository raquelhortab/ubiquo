module UbiquoMenus
  module Connectors
    class I18n < Standard

      # Validates the ubiquo_i18n-related dependencies
      def self.validate_requirements
        unless Ubiquo::Plugin.registered[:ubiquo_i18n]
          raise ConnectorRequirementError, "You need the ubiquo_i18n plugin to load #{self}"
        end
        [::MenuItem, ::Menu].each do |klass|
          if klass.table_exists?
            klass.reset_column_information
            columns = klass.columns.map(&:name).map(&:to_sym)
            unless [:locale, :content_id].all?{|field| columns.include? field}
              if Rails.env.test?
                ::ActiveRecord::Base.connection.change_table(klass.table_name, :translatable => true){}
                klass.reset_column_information
              else
                raise ConnectorRequirementError,
                  "The #{klass.table_name} table does not have the i18n fields. " +
                  "To use this connector, update the table enabling :translatable => true"
              end
            end
          end
        end
      end

      def self.unload!
        [::MenuItem, ::Menu].each { |klass| klass.untranslatable }
        # Unfortunately there's no neat way to clear the helpers mess
        %w{MenuItems Menus}.each do |controller_name|
          ::Ubiquo.send(:remove_const, "#{controller_name}Controller")
          load "ubiquo/#{controller_name.tableize}_controller.rb"
        end
      end

      module ApplicationHelper
        def self.included(klass)
          klass.send :include, InstanceMethods
          I18n.register_uhooks klass, InstanceMethods
        end
        module InstanceMethods
          def uhook_find_by_key(key)
            if @menus
              @menus.select{|m| m.key == key && m.locale == current_locale}.first
            else
              ::Menu.locale(current_locale).find_by_key(key)
            end
          end
          def uhook_build_menu_items_array(array, menu_items, parent_id = nil)
            #We have to select the items which have the parent_id we look for,
            #or the corresponding translation
            unless parent_id
              menu_items.select{|item|
                items = ::MenuItem.all(:conditions => {:content_id => item.content_id})
                (items.flatten.map(&:parent_id).compact.blank? rescue false)
              }.sort{|a, b| a.position.to_i <=> b.position.to_i
              }.each do |item|
                array << {:item => item, :children => []}
                uhook_build_menu_items_array(array.last[:children], menu_items, item.id)
              end
            else
              parent = menu_items.select{|item| item.id == parent_id}.first
              parents_ids = ::MenuItem.all(:conditions => {:content_id => parent.content_id}).map(&:id)
              menu_items.select{|item| parents_ids.include?(item.parent_id) && item.locale == Locale.current}.
                sort_by{|item| item.position.to_i}.each do |item|
                array << {:item => item, :children => []}
                uhook_build_menu_items_array(array.last[:children], menu_items, item.id)
              end
            end
          end

          def uhook_get_menu_items(menu)
            if @menu_items
              menu_ids = @menus.select{|m| m.content_id == menu.content_id}.map(&:id)
              items = @menu_items.select{|item| menu_ids.include?(item.menu_id)}
              Scope.filter_by_locale(items, Locale.current)
              ::MenuItem.filter_by_locale(items, Locale.current)
            else
              menu.menu_items
            end
          end
        end
      end

      module MenuItem
        def self.included(klass)
          klass.send :include, InstanceMethods
          I18n.register_uhooks klass, InstanceMethods
          klass.send :translatable, :caption, :url, :description, :position
          klass.share_translations_for :children, :parent, :menu
        end
        module InstanceMethods
          # Before creating a menu_item record, set a sane position index (last + 1)
          def uhook_initialize_position
            # TODO review and test this
            # was not finding translations and not initializing parent_id,
            # since it created a sql with self.locale != NULL
            if self.translations.present?
              position = self.translations.first.position
              conditions = {
                :parent_id => self.parent_id,
                :menu_id => self.menu_id,
                :position => self.position,
                :locale => self.locale
              }
              if !self.class.find(:first, :conditions => conditions)
                self.position = position
                return
              end
            end
            conditions = {
              :parent_id => self.parent_id,
              :locale => self.locale
            }
            max_position = ::MenuItem.maximum(:position, :conditions => conditions)
            self.position = (max_position || 0) + 1
          end

          def uhook_skip_for_position_calculation?
            !self.in_locale?(Locale.current)
          end
        end
      end

      module Menu
        def self.included(klass)
          klass.send :translatable, :name
          klass.share_translations_for :menu_items
          klass.send(:validates_uniqueness_of,
                     :key,
                     :scope       => [:locale],
                     :allow_blank => true,
                     :case_sensitive => false)
          klass.send(:extend, ClassMethods)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods, ClassMethods
        end
        module InstanceMethods
          include UbiquoMenus::Connectors::Standard::Menu::InstanceMethods

        end
        module ClassMethods
          include UbiquoMenus::Connectors::Standard::Menu::ClassMethods

          # loads menus priorizing the one in the current_locale
          def find_all current_locale = nil, options = {}
            ::Menu.locale(current_locale, options[:extra_locales] || :all)
          end
        end
      end

      module UbiquoMenuItemsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          include Standard::UbiquoMenuItemsController::InstanceMethods

          # gets Menu items instances for the list and return it
          def uhook_find_menu_items
            ::Menu.find(params[:menu_id]).menu_items.locale(current_locale, :all)
          end

          # initialize a new instance of menu item
          def uhook_new_menu_item
            ::MenuItem.translate(params[:from], current_locale).tap do |menu_item|
              if menu_item.content_id.to_i == 0
                menu_item.attributes = {
                  :menu_id => params[:menu_id],
                  :parent_id => params[:parent_id],
                  :is_active => true
                }
              end
            end
          end

          # redirect to the menu if the menu_item to edit is not in the current_locale
          def uhook_edit_menu_item(menu_item)
            unless menu_item.in_locale?(current_locale)
              redirect_to(ubiquo_menu_menu_items_path(menu_item.menu))
              false
            end
          end

          #destroys a menu item instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu_item(menu_item)
            menu_item.destroy_content
          end

        end

        module Helper
          include Standard::UbiquoMenuItemsController::Helper

          #extra field to link translations
          def uhook_extra_hidden_fields(form)
            form.hidden_field :content_id
          end

          #links for each menu_item
          def uhook_menu_item_links(menu_item)
            links = []
            if menu_item.menu
              if menu_item.in_locale?(current_locale)
                links << edit_menu_item_link(menu_item)
              else
                links << translate_menu_item_link(menu_item)
              end

              if menu_item.in_locale?(current_locale, :skip_any => true) &&
                  !menu_item.translations.empty?
                destroy_translation_menu_item_link(menu_item)
              end

              links << destroy_menu_item_link(menu_item) if menu_item.can_be_destroyed?

              if menu_item.in_locale(current_locale) && menu_item.can_have_children?
                links << new_menu_item_subsection(menu_item)
              end
            end
            links
          end

          protected

          def destroy_translation_menu_item_link(menu_item)
            link_to(
              t("ubiquo.remove_translation"),
              ubiquo_menu_menu_item_path(menu_item.menu, menu_item),
              :confirm => t("ubiquo.menus.confirm_menu_item_removal"),
              :method => :delete)
          end

          def translate_menu_item_link(menu_item)
            link_to(t("ubiquo.translate"),
                    new_ubiquo_menu_menu_item_path(
                      :from => menu_item.content_id,
                      :menu_id => menu_item.menu_id
                    )
            )
          end
        end
      end


      module UbiquoMenusController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          include Standard::UbiquoMenusController::InstanceMethods

          # gets Menu instances for the list and return it
          def uhook_find_menus
            ::Menu.find_all(current_locale).paginated_filtered_search(params)
          end

          # initialize a new instance of menu
          def uhook_new_menu
            @forbid_item_creation = forbid_item_creation?
            ::Menu.translate(params[:from], current_locale)
          end

          # creates and returns a new instance of menu
          def uhook_create_menu
            # menu_items_attributes treatment is delayed since it needs other params
            # that are in params[:menu], so we preserve the order by setting them later
            attrs = params[:menu].delete(:menu_items_attributes) rescue nil
            ::Menu.new(params[:menu]).tap do |menu|
              menu.locale = Locale.current
              menu.save
              if attrs.present?
                attrs.keys.sort{|a,b| a.to_i <=> b.to_i}.inject(1) do |position, key|
                  attrs[key]["position"] = position
                  position + 1
                end
                menu.update_attributes(:menu_items_attributes => attrs) if attrs.present?
                menu.save
              end
            end
          end

          # redirect to the menu index if the menu to edit is not in the current_locale
          def uhook_edit_menu(menu)
            unless menu.in_locale?(current_locale)
              if localized_menu = menu.in_locale(current_locale)
                redirect_to edit_ubiquo_menu_path(localized_menu)
                false
              else
                redirect_to(ubiquo_menus_path)
                false
              end
            end
            true
          end

          #destroys a menu instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu(menu)
            menu.destroy_content
          end

          protected

          def forbid_item_creation?
            params.key?(:from)
          end
        end

        module Helper
          include Standard::UbiquoMenusController::Helper
          include I18n::UbiquoMenuItemsController::Helper

          # Returns content to show in the sidebar when editing a menu
          def uhook_edit_menu_sidebar menu
            show_translations(menu, :hide_preview_link => true)
          end

          # Returns content to show in the sidebar when creating a menu
          def uhook_new_menu_sidebar menu
            show_translations(menu, :hide_preview_link => true)
          end

          #extra field to link translations
          def uhook_extra_hidden_fields(form)
            form.hidden_field :content_id
          end

          #links for each menu
          def uhook_menu_links(menu, options = {})
            show_elements = options[:show_elements] || false
            links = []

            links << link_to(t('ubiquo.menu.menu_items_index'), ubiquo_menu_menu_items_path(menu)) if show_elements
            if menu.in_locale?(current_locale)
              links << edit_menu_link(menu)
            else
              links << translate_menu_link(menu)
            end

            links << destroy_translation_menu_link(menu) unless menu.key.present?
            links << destroy_menu_link(menu) unless menu.key.present?

            links
          end

          protected

          def destroy_translation_menu_link(menu)
            link_to(
              t('ubiquo.remove_translation'),
              [:ubiquo, menu],
              :confirm => t('ubiquo.menus.confirm_menu_removal'),
              :method  => :delete
            )
          end

          def translate_menu_link(menu)
            link_to(t("ubiquo.translate"), new_ubiquo_menu_path(:from => menu.content_id))
          end
        end
      end

      module Migration
        def self.included(klass)
          klass.send(:extend, ClassMethods)
          I18n.register_uhooks klass, ClassMethods
        end
        module ClassMethods
          include Standard::Migration::ClassMethods

          def uhook_create_menu_items_table
            create_table :menu_items, :translatable => true do |t|
              yield t
            end
          end

          def uhook_create_menus_table
            create_table :menus, :translatable => true do |t|
              yield t
            end
          end
        end
      end
    end

  end
end
