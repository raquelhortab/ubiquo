class Category < ActiveRecord::Base
  
  translatable :name, :description

  belongs_to :category_set
  
  validates_presence_of :name, :category_set
    
  # See vendor/plugins/ubiquo_core/lib/ubiquo/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      when :text
        {:conditions => ["upper(categories.name) LIKE upper(?)", "%#{value}%"]}
      when :locale
        {:conditions => {:locale => value}}
      when :category_set
        {:conditions => {:category_set_id => value}}
      end
    end
    
    apply_find_scopes(scopes) do
      find(:all, options)
    end
  end
  
end
