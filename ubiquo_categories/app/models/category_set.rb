class CategorySet < ActiveRecord::Base

  has_many :categories do
    def << categories
      categories = [categories] unless categories.is_a? Array
      categories.each do |category|
        case category
        when String
          self.concat(Category.new(:name => category))
        else
          self.concat(category)
        end
      end
    end
  end

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
