class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %><%= options[:versionable] ? ", :versionable => true" : "" -%><%= options[:translatable] ? ", :translatable => true" : "" -%> do |t|
<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
<% unless options[:skip_timestamps] %>
      t.timestamps
<% end -%>
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
