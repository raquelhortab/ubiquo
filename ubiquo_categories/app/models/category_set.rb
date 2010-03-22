class CategorySet < ActiveRecord::Base

  has_many :categories do
    def << categories
      categories = [categories] unless categories.is_a? Array
      categories.each do |category|
        # skip if already added
        load_target
        next if proxy_target.map(&:to_s).include? category.to_s
          
        case category
        when String
          raise UbiquoCategories::CreationNotAllowed unless proxy_owner.is_editable?
          self.concat(Category.new(:name => category))
        else
          self.concat(category)
        end
      end
    end
  end

  validates_presence_of :name

  def initialize(attrs = {})
    attrs ||= {}
    attrs.reverse_merge!(:is_editable => true)
    super attrs
  end



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

  # sets the set as editable
  def is_editable!
    update_attribute :is_editable, true
  end

  # sets the set as not editable
  def is_not_editable!
    update_attribute :is_editable, false
  end

end
