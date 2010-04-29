class Category < ActiveRecord::Base
  
  belongs_to :category_set
  
  validates_presence_of :name, :category_set
    
  # See vendor/plugins/ubiquo_core/lib/ubiquo/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      when :text
        {:conditions => ["upper(categories.name) LIKE upper(?)", "%#{value}%"]}
      when :category_set
        {:conditions => {:category_set_id => value}}
      end
    end

    scopes += uhook_filtered_search(filters)
    
    apply_find_scopes(scopes) do
      find(:all, options)
    end
  end

  def to_s
    name
  end
  
end
