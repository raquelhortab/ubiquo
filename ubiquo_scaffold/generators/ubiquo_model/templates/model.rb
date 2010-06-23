class <%= class_name %> < ActiveRecord::Base

  <%- if options[:versionable] -%>
  versionable <%= options[:versions_amount] ? " :max_amount => #{options[:versions_amount]}" : "" %>

  <%- end -%>
  <%- if options[:translatable] -%>
  translatable <%= options[:translatable].map{|i| ":#{i}"}.join(", ") %>

  <%- end -%>
  <%- unless ton.nil? -%>
  validates_presence_of :<%= ton %>
  <%- end -%>

  filtered_search_scopes

end
