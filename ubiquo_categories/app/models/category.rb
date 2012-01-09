class Category < ActiveRecord::Base
  
  belongs_to :category_set
  has_many :category_relations
  belongs_to :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'
  
  validates_presence_of :name, :category_set

  named_scope :category_set, lambda {|value| {:conditions => {:category_set_id => value}}}

  filtered_search_scopes :text => [:name], :enable => [:category_set]

  #For backwards compatibility
  def self.filtered_search(filters = {}, options = {})
    new_filters = {}
    filters.each do |key, value|
      if key == :text
        new_filters["filter_text"] = value
      elsif key == :category_set
        new_filters["filter_category_set"] = value
      else
        new_filters[key] = value
      end
    end

    super new_filters, options
  end

  def to_s
    name
  end
  
  def self.alias_for_association association_name
    connection.table_alias_for "#{table_name}_#{association_name}"
  end
end
