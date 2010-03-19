class CategorySet < ActiveRecord::Base

  has_many :categories

  validates_presence_of :name
    
  # See vendor/plugins/ubiquo_core/lib/ubiquo/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      when :text
        {:conditions => ["upper(category_sets.name) LIKE upper(?)", "%#{value}%"]}
      end
    end
    
    apply_find_scopes(scopes) do
      find(:all, options)
    end
  end
  
end
