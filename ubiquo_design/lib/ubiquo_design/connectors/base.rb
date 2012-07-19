module UbiquoDesign
  module Connectors
    class Base < Ubiquo::Connectors::Base

      # loads this connector. It's called if that connector is used
      def self.load!
        ::Widget.reset_column_information if Object.const_defined? 'Widget'
        if current = UbiquoDesign::Connectors::Base.current_connector
          current.unload!
        end
        validate_requirements
        :Page.include! self::Page
        :PagesController.include! self::PagesController
        :"Ubiquo::DesignsController".include! self::UbiquoDesignsHelper
        :"Ubiquo::WidgetsController".include! self::UbiquoDesignsHelper
        :"Ubiquo::BlocksController".include! self::UbiquoDesignsHelper
        :"Ubiquo::WidgetsController".include! self::UbiquoWidgetsController
        :"Ubiquo::StaticPagesController".include! self::UbiquoStaticPagesController
        :"Ubiquo::PagesController".include! self::UbiquoPagesController
        ::ActiveRecord::Migration.send(:include, self::Migration)
        :"UbiquoDesign::RenderPage".include! self::RenderPage
        UbiquoDesign::Connectors::Base.set_current_connector self
      end

    end
  end
end
