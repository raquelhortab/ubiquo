module UbiquoMedia
  module Connectors
    class Base < Ubiquo::Connectors::Base

      # Load all the modules required for an UbiquoMedia connector
      def self.load!
        # As we can create new fields, if these models are loaded we clean them
        %w{Asset AssetPublic AssetPrivate AssetRelation}.each do |const|
          if Object.const_defined? const
            Object.const_get(const).reset_column_information
          end
        end

        # Unload the previous connector
        if current = UbiquoMedia::Connectors::Base.current_connector
          current.unload!
        end

        validate_requirements
        prepare_mocks if Rails.env.test?

        ::ActiveRecord::Base.send(:include, self::ActiveRecord::Base)
        :Asset.include! self::Asset
        :AssetRelation.include! self::AssetRelation
        :"Ubiquo::AssetsController".include! self::UbiquoAssetsController
        ::ActiveRecord::Migration.send(:include, self::Migration)
        UbiquoMedia::Connectors::Base.set_current_connector self
      end

    end
  end
end
