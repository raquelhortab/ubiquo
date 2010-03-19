class CategoryRelation < ActiveRecord::Base
  
  belongs_to :category
  belongs_to :related_object, :polymorphic => true

  validates_presence_of :category, :related_object
    
  # See vendor/plugins/ubiquo_core/lib/ubiquo/extensions/active_record.rb to see an example of usage.
  def self.filtered_search(filters = {}, options = {})
    
    scopes = create_scopes(filters) do |filter, value|
      case filter
      when :text
        {}
      end
    end
    
    apply_find_scopes(scopes) do
      find(:all, options)
    end
  end
  
end
