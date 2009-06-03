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
    
  # See vendor/plugins/ubiquo_core/lib/ubiquo/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      <%- if !ton.nil? -%>
      when :text
        {:conditions => ["upper(<%= file_name.pluralize %>.<%= ton %>) LIKE upper(?)", "%#{value}%"]}
      <%- end -%>
      <%- if options[:translatable] -%>
      when :locale
        {:conditions => {:locale => value}}
      <%- end -%>
      <%- if has_published_at -%>
      when :publish_start
        {:conditions => ["<%= file_name.pluralize %>.published_at >= ?", value]}
      when :publish_end
        {:conditions => ["<%= file_name.pluralize %>.published_at <= ?", value]}
      <%- end -%>
      <%- if ton.nil? && !has_published_at -%>
      when :text
        {}
      <%- end -%>
      end
    end
    
    apply_find_scopes(scopes) do
      find(:all, options)
    end
  end
  
end
