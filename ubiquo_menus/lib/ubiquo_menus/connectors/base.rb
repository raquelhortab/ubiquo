module UbiquoMenus
  module Connectors
    class Base < Ubiquo::Connectors::Base

      # Load all the modules required for an UbiquoMenus connector
      def self.load!
        [::MenuItem].each(&:reset_column_information)
        [::Menu].each(&:reset_column_information)      
        if current = UbiquoMenus::Connectors::Base.current_connector
          current.unload!
        end
        validate_requirements
        ::Menu.send(:include, self::Menu) if self::Menu != ::Menu
        ::MenuItem.send(:include, self::MenuItem) if self::MenuItem != ::MenuItem
        ::Ubiquo::MenuItemsController.send(:include, self::UbiquoMenuItemsController)
        ::Ubiquo::MenusController.send(:include, self::UbiquoMenusController)
        ::ActiveRecord::Migration.send(:include, self::Migration)

        ActionController::Base.helper(self::ApplicationHelper)
        ActionView::Base.send(:include, self::ApplicationHelper)
        
        UbiquoMenus::Connectors::Base.set_current_connector self
      end
    end
  end
end
