module Ubiquo
  module Adapters
    module SchemaStatements

      def self.included(klass)
        klass.send(:alias_method_chain, :drop_table, :sequences)
      end

      # Performs the usual drop_table action, but remove also the created sequences
      # that are related with this table
      def drop_table_with_sequences(table_name)
        drop_table_without_sequences(table_name)
        ActiveRecord::Base.connection.list_sequences(table_name.to_s + "_$").each do |sequence|
          unless sequence =~ /id_seq/ || @using_force
            ActiveRecord::Base.connection.drop_sequence sequence
          end
        end
      end

      # Performs the usual create_table action, but records in an instance variable
      # if we are using the :force option, since we need it in the above method,
      # but the drop_table signature no longer includes
      def create_table(table_name, options={})
        @using_force = options[:force]
        super
        @using_force = nil
      end

      # Undoes the field and sequence created by the add_sequence_field method
      def remove_sequence_field(table_name, field_name)
        change_table(table_name) do |t|
          t.remove_sequence table_name, field_name
        end
      end

      # Undoes the field and sequence created by the SchemaStatements#sequence method
      def add_sequence_field(table_name, field_name)
        change_table(table_name) do |t|
          t.sequence table_name, field_name
        end
      end
    end
  end
end
