module UbiquoMenus
  module Connectors
    class Standard < Base
      module ApplicationHelper
        def self.included(klass)
          klass.send :include, InstanceMethods
          Standard.register_uhooks klass, InstanceMethods
        end
        module InstanceMethods
          def uhook_find_by_key(key)
            if @menus
              @menus.select{|m| m.key == key}.first
            else
              ::Menu.find_by_key(key)
            end
          end

          #Build an arrayed version of the entire menu
          def uhook_build_menu_items_array(array, menu_items, parent_id = nil)
            menu_items.select{|item| item.parent_id == parent_id}.sort_by{|item| item.position.to_i}.each do |item|
              array << {:item => item, :children => []}
              uhook_build_menu_items_array(array.last[:children], menu_items, item.id)
            end
          end

          def uhook_get_menu_items(menu)
            if @menu_items
              items = @menu_items.select{|item| item.menu_id == menu.id}
            else
              menu.menu_items
            end
          end

        end
      end

      module MenuItem
        def self.included(klass)
          klass.send :include, InstanceMethods
          Standard.register_uhooks klass, InstanceMethods
        end
        module InstanceMethods
          # Before creating a menu_item record, set a sane position index (last + 1)
          def uhook_initialize_position
            siblings_positions = [0] + siblings.map(&:position)
            self.position = siblings_positions.max + 1
          end

          def uhook_skip_for_position_calculation?
            false
          end
        end
      end

      module UbiquoMenuItemsController

        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods

          # gets root MenuItem instances for the menu
          def uhook_find_menu_items
            ::Menu.find(params[:menu_id]).menu_items
          end

          # initialize a new instance of menu item
          def uhook_new_menu_item
            ::MenuItem.new(:parent_id => params[:parent_id], :is_active => true, :menu_id => params[:menu_id])
          end
          def uhook_edit_menu_item(menu_item)
            true
          end


          # creates a new instance of menu item
          def uhook_create_menu_item
            mi = ::MenuItem.new(params[:menu_item])
            mi.save
            mi
          end

          #updates a menu item instance. returns a boolean that means if update was done.
          def uhook_update_menu_item(menu_item)
            menu_item.update_attributes(params[:menu_item])
          end

          #destroys a menu item instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu_item(menu_item)
            menu_item.destroy
          end

        end
        module Helper
          def uhook_extra_hidden_fields(form)
          end

          #links for each menu_item of the menu
          def uhook_menu_item_links(menu_item)
            links = []
            if menu_item.menu
              links << edit_menu_item_link(menu_item)
              links << destroy_menu_item_link(menu_item) if menu_item.can_be_destroyed?
              links << new_menu_item_subsection(menu_item) if menu_item.can_have_children?
              links
            end
            links
          end

          protected

          def edit_menu_item_link(menu_item)
            link_to(t("ubiquo.edit"),
                    ubiquo.edit_menu_menu_item_path(menu_item.menu, menu_item),
                    :class => "btn-edit lightwindow",
                    :params => "lightwindow_form=menu_item_edit_form,lightwindow_width=710",
                    :type => 'page')
          end

          def destroy_menu_item_link(menu_item)
            link_to(t("ubiquo.remove"),
                ubiquo.menu_menu_item_path(menu_item.menu, menu_item, :destroy_content => true),
                :confirm => t("ubiquo.menus.confirm_menu_item_removal"),
                :method => :delete,
                :class => "btn-delete")
          end

          def new_menu_item_subsection(menu_item)
            link_to(t("ubiquo.menu_item.new_subsection"),
                    ubiquo.new_menu_menu_item_path(menu_item.menu, :parent_id => menu_item.id),
                    :class => "lightwindow",
                    :params => "lightwindow_form=menu_item_subsection_form,lightwindow_width=710",
                    :type => 'page')
          end
        end
      end

      module UbiquoMenusController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods

          # gets Menus instances
          def uhook_find_menus
            ::Menu.paginated_filtered_search(params)
          end

          # initialize a new instance of menu
          def uhook_new_menu
            return ::Menu.new
          end

          def uhook_edit_menu(menu)
            true
          end

          def uhook_load_menu
            return ::Menu.find(params[:id])
          end

          # creates a new instance of menu
          def uhook_create_menu
            attrs = params[:menu].delete(:menu_items_attributes) rescue nil
            mi = ::Menu.new(params[:menu])
            mi.save
            mi.update_attributes(:menu_items_attributes => attrs) if attrs.present?
            mi.save
            mi
          end

          #updates a menu instance. returns a boolean that means if update was done.
          def uhook_update_menu(menu)
            menu.update_attributes(params[:menu])
          end

          #destroys a menu instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu(menu)
            menu.destroy
          end

        end
        module Helper
          include Standard::UbiquoMenuItemsController::Helper

          # Returns content to show in the sidebar when editing a menu
          def uhook_edit_menu_sidebar menu
            ''
          end

          # Returns content to show in the sidebar when creating a menu
          def uhook_new_menu_sidebar menu
            ''
          end

          def uhook_extra_hidden_fields(form)
          end

          def uhook_menu_links(menu, options = {})
            links = []

            links << edit_menu_link(menu)
            links << destroy_menu_link(menu) unless menu.key.present?

            links
          end

          protected

          def edit_menu_link(menu)
            link_to(t('ubiquo.edit'), ubiquo.edit_menu_path(menu), :class => "btn-edit")
          end

          def destroy_menu_link(menu)
            link_to(
              t('ubiquo.remove'),
              ubiquo.menu_path(menu, :destroy_content => true),
              :confirm => t('ubiquo.menus.confirm_menu_removal'),
              :method  => :delete,
              :class => "btn-delete"
            )
          end
        end
      end

      module Menu
        def self.included(klass)
          klass.send(:validates_uniqueness_of, :key, :allow_blank => true, :case_sensitive => false)
          klass.send(:extend, ClassMethods)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods, ClassMethods
        end
        module InstanceMethods

        end
        module ClassMethods
          def find_all(unused = nil, extra_unused = nil)
            ::Menu.all
          end
        end
      end

      module Migration
        def self.included(klass)
          klass.send(:extend, ClassMethods)
          Standard.register_uhooks klass, ClassMethods
        end
        module ClassMethods
          def uhook_create_menu_items_table
            create_table :menu_items do |t|
              yield t
            end
          end
          def uhook_create_menus_table
            create_table :menus do |t|
              yield t
            end
          end
        end
      end

    end
  end
end
