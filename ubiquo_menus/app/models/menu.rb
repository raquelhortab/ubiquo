class Menu < ActiveRecord::Base

  has_many :menu_items, :dependent => :destroy, :order => :position
  alias_method :children, :menu_items

  accepts_nested_attributes_for :menu_items,
                                :allow_destroy => true,
                                :reject_if => lambda { |a| MenuItem.new(a.reject{|k,_| k == "_destroy"}).blank? }

  before_validation :generate_key, :if =>  lambda { |m| m.force_key }
  validates :name, :presence => true

  after_save :update_positions!

  filtered_search_scopes :enable => [:text],
                          :text => [ :name, :key ]

  def root_menu_items
    self.menu_items.select(&:is_root?)
  end

  def force_key=(value)
    @force_key = value
  end

  def force_key
    @force_key || false
  end

  def update_positions!(items = self.menu_items)
    proper_menu_items = items.map do |item|
      item.is_a?(MenuItem) ? item : MenuItem.find(item)
    end.compact
    proper_menu_items.inject(1) do |position, menu_item|
      #
      #  - items that are not exclusively mine, should be ignore for position
      #  calculation. i.e. items in other locale
      #  - items that have been deleted via nested_attributes will still exists
      #  but should be ignored
      unless menu_item.uhook_skip_for_position_calculation? || menu_item.frozen?
        menu_item.update_attribute(:position, position)
      end
      position + 1
    end
  end

  protected

  def generate_key
    if self.key.blank? && self.name.present?
      self.key = self.name.parameterize.underscore.to_s
    end
  end
end
