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
<%- if options[:categorized] -%>
<%- options[:categorized].each do |categorized| -%>
<%- category_set_key = categorized.pluralize -%>
    unless CategorySet.find_by_key(<%= category_set_key.to_json %>)
      CategorySet.create(:key => <%= category_set_key.to_json %>, :name => <%= category_set_key.humanize.to_json %>)
    end
<% end -%>
<% end -%>
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
