module UbiquoI18n
  module Adapters
    # Extends the create_table method to support the :translatable option
    module SchemaStatements
      extend ActiveSupport::Concern

      # Perform the actual linking with create_table
      included do
        include Ubiquo::Tasks::Database
        alias_method :create_table_without_translatable, :create_table
        alias_method :change_table_without_translatable, :change_table
      end

      # Parse the :translatable option as a create_table extension
      # This will currently add two fields:
      #   table.locale: string
      #   table.content_id sequence
      # with their respective indexes
      def create_table(*args, &block)
        apply_translatable_option!(:create_table, block, *args) do |definition|
          super(*args, &definition)
        end
      end

      # Parse the :translatable option as a change_table extension
      # This will currently add two fields:
      #   table.locale: string
      #   table.content_id sequence
      # with their respective indexes
      def change_table(*args, &block)
        apply_translatable_option!(:change_table, block, *args) do |definition|
          super(*args, &definition)
        end
      end

      # Performs the actual job of applying the :translatable option
      def apply_translatable_option!(method, definition, table_name, options = {})
        translatable = options[:translatable]
        locale       = options[:locale]

        yield(lambda do |table|
          if translatable
            table.string :locale, :nil => false
            table.sequence table_name, :content_id
          elsif translatable == false && method == :change_table
            table.remove :locale
            table.remove_sequence :test, :content_id
          end
          definition.call(table)
        end)

        if translatable && method == :change_table
          fill_i18n_fields(table_name, locale)
        end

        # Create or remove indexes for these new fields. Skip it in tests for speed
        return if Rails.env.test?
        if translatable
          create_i18n_indexes
        elsif translatable == false # != nil
          remove_i18n_indexes
        end
      end

      @i18n_indexes = [:locale, :content_id]

      # creates indexes for the i18n fields, unless they already exist
      def create_i18n_indexes
        @i18n_indexes.each do |index|
          unless indexes(table_name).map(&:columns).flatten.include? index.to_s
            add_index table_name, index
          end
        end
      end

      # removes indexes for the i18n fields, if they exist
      def remove_i18n_indexes
        @i18n_indexes.each do |index|
          if indexes(table_name).map(&:columns).flatten.include? index.to_s
            remove_index table_name, index
          end
        end
      end

      # In an existing table, fills the content_id and locale fields
      def fill_i18n_fields(table, locale)
        table_name = quote_table_name(table)

        # set content_id = id
        update("UPDATE #{table_name} SET #{quote_column_name('content_id')} = #{quote_column_name('id')}")
        fix_sequence_consistency([table_name])

        # fill the locale field for existing records
        locale ||= Locale.default
        update("UPDATE #{table_name} SET #{quote_column_name('locale')} = #{quote(locale)}")
      end

    end
  end
end
