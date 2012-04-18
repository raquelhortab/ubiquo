class MenuItem < ActiveRecord::Base

  belongs_to :menu
  belongs_to :parent,
             :class_name => "MenuItem",
             :foreign_key => :parent_id

  has_many :children,
           :class_name => "MenuItem",
           :foreign_key => :parent_id,
           :order => :position,
           :dependent => :destroy
  belongs_to :page

  # set to true if we are building this item with nested attributes from a menu
  attr_accessor :nested

  before_validation :initialize_position, :on => :create,
                                          :if => lambda { |i| i.position.nil? }
  before_validation :priorize_page
  before_validation :clear_link

  validates :caption, :presence =>  true
  validates :menu, :presence => true, :unless => :nested
  validate :validate_link

  scope :active, where(:is_active => true)
  # must be done with uhook
  scope :roots, where(:parent_id => nil).order("position ASC")

  # must be done with uhook
  scope :menu, lambda { |value|   where(:menu_id => value) }
  scope :sort, lambda { |*params| order("#{params.first || 'menu_items.position ASC'}") }

  # must be done via uhook
  # Return the items assigned to a menu and the free available to assign
  scope :availables, lambda { |*menu_id|
    id = menu_id.first
    where(["menu_items.parent_id IS NULL AND (menu_items.menu_id = ? OR menu_items.menu_id IS NULL)", id])
  }

  filtered_search_scopes :enable => [:text], :text => [:caption]

  # Returns true if is a root node
  def is_root?
    self.parent.nil?
  end

  # Returns true if this node is allowed to have children.
  # For now, only root nodes can have children.
  def can_have_children?
    max_menu_depth = Ubiquo::Settings[:ubiquo_menus][:menu_depth]
    max_menu_depth > 0 && self.depth < max_menu_depth
    true
  end

  def can_be_destroyed?
    self.key.blank?
  end

  # Return an array containing active root (first-level) menu items
  def self.active_roots
    self.active.roots
  end

  # Return active children for a node
  def active_children
    self.children.active
  end

  def link_type
    return "UNLINKED" if !self.is_linkable
    return "PAGE" if self.page.present?
    "URL"
  end

  def link_type=(value)
    self.is_linkable = (value !="UNLINKED")
  end

  def self.link_types
    [:unlinked, :page, :url]
  end

  def self.translated_link_types
    link_types.map do |link_type|
      [I18n.t("ubiquo.menu_item.link_type.#{link_type}"), link_type.to_s.upcase]
    end
  end

  def link
    return page if self.page.present?
    return self.url if self.url.present?
    return ""
    raise 'No link available for menu #{menu.id}-#{menu.name}'
  end

  def depth
    if parent
      1 + parent.depth
    else
      1
    end
  end

  def blank?
    caption.blank? && url.blank? && page.blank?
  end

  def siblings
    parent = self.parent || self.menu
    parent ? parent.children : self.class.availables(safe_menu_id)
  end

  private

  def safe_menu_id
    menu ? menu.id : nil
  end

  def clear_link
    if(!self.is_linkable)
      self.url = ""
      self.page_id = nil
    end
  end

  def priorize_page
    self.url = nil if self.page.present?
  end

  def validate_link
    self.errors.add :url if self.is_linkable && self.url.blank? && self.page.blank?
  end

  # Before creating a menu_item record, set a sane position index (last + 1)
  def initialize_position
    uhook_initialize_position
  end

end
