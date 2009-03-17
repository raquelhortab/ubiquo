class <%= class_name %> < ActiveRecord::Base
  
  <%- unless ton.nil? -%>
  validates_presence_of :<%= ton %>
  <%- end -%>
  
  # See vendor/plugins/ubiquo_base/lib/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      <%- if !ton.nil? -%>
      when :text
        {:conditions => ["<%= file_name.pluralize %>.<%= ton %> ILIKE ?", "%#{value}%"]}
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
