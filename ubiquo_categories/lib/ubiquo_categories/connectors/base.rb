module UbiquoCategories
  module Connectors
    class Base < Ubiquo::Connectors::Base

      # Load all the modules required for an UbiquoCategories connector
      def self.load!
        ::Category.reset_column_information
        if current = UbiquoCategories::Connectors::Base.current_connector
          current.unload!
        end
        return if validate_requirements == false
        prepare_mocks if Rails.env.test?
        ::ActiveRecord::Base.send(:include, self::ActiveRecord::Base)
        loader = Ubiquo::Extensions::Loader
        loader.append_include(:Category, self::Category)
        loader.append_include(:CategorySet, self::CategorySet)
        loader.append_helper(:UbiquoController, self::UbiquoHelpers::Helper)
        loader.append_include(:"Ubiquo::CategoriesController", self::UbiquoCategoriesController)
        ::ActiveRecord::Migration.send(:include, self::Migration)
        UbiquoCategories::Connectors::Base.set_current_connector self
      end

    end
  end
end
