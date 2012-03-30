module UbiquoI18n
  module Adapters
    autoload :SchemaStatements, "ubiquo_i18n/adapters/schema_statements"
  end
end


ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, UbiquoI18n::Adapters::SchemaStatements)
