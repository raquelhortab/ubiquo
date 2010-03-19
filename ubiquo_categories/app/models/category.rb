class Category < ActiveRecord::Base
  
  translatable :name, :description
  
  validates_presence_of :name
    
  # See vendor/plugins/ubiquo_core/lib/ubiquo/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      when :text
        {:conditions => ["upper(categories.name) LIKE upper(?)", "%#{value}%"]}
      when :locale
        {:conditions => {:locale => value}}
      end
    end
    
    apply_find_scopes(scopes) do
      find(:all, options)
    end
  end
  
end
