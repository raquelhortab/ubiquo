require File.dirname(__FILE__) + "/../test_helper.rb"

class MenuItemTest < ActiveSupport::TestCase

  def setup
    UbiquoMenus::Connectors::Standard.load!
  end

  def test_should_create_menu_item
    assert_difference 'MenuItem.count' do
      menu_item = create_menu_item
      assert !menu_item.new_record?, "#{menu_item.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_url_if_is_linkable
    assert_no_difference 'MenuItem.count' do
      menu_item = create_menu_item(:url => "", :is_linkable => true)
      assert menu_item.errors.include?(:url)
    end
  end

  def test_should_require_caption
    assert_no_difference 'MenuItem.count' do
      menu_item = create_menu_item(:caption => nil)
      assert menu_item.errors.include?(:caption)
    end
  end

  def test_should_get_root_menu_items_ordered_by_position
    MenuItem.delete_all
    Menu.delete_all
    root1 = create_menu_item(:caption => 'caption1', :position => 1)
    root2 = create_menu_item(:caption => 'caption2', :position => 2)
    root3 = create_menu_item(:caption => 'caption3', :position => 3)
    child11 = create_menu_item(:caption => 'caption11', :parent_id => root1.id, :position => 1)
    child31 = create_menu_item(:caption => 'caption31', :parent_id => root3.id, :position => 1)
    assert_equal MenuItem.roots, [root1, root2, root3]
  end

  def test_should_set_next_position_on_create_menu_item
    Menu.delete_all
    root1 = create_menu_item(:caption => 'caption1', :position => 1)
    root2 = create_menu_item(:caption => 'caption2', :position => nil)
    assert_equal root1.position + 1, root2.position
  end

  def test_should_respect_position_if_already_set
    root = create_menu_item(:caption => 'caption1', :position => 100)
    assert_equal 100, root.position
  end

  def test_should_return_childs
    Menu.delete_all
    MenuItem.delete_all
    root1 = create_menu_item(:caption => 'caption1')
    child11 = create_menu_item(:caption => 'caption11', :parent_id => root1.id)
    child12 = create_menu_item(:caption => 'caption12', :parent_id => root1.id)
    root1.children = [child11, child12]
    root1.save
    assert_equal root1.children, [child11, child12]
  end

  def test_should_return_parent
    Menu.delete_all
    root1 = create_menu_item(:caption => 'caption1')
    child11 = create_menu_item(:caption => 'caption11', :parent_id => root1.id)
    child12 = create_menu_item(:caption => 'caption12', :parent_id => root1.id)
    assert_equal child11.parent, root1
  end

  def test_active_roots
    MenuItem.delete_all
    active_root = create_menu_item(:is_active => true)
    create_menu_item(:is_active => false)
    create_menu_item(:parent => active_root, :is_active => true)
    active_roots = MenuItem.active_roots
    assert_equal [active_root], active_roots
  end

  def test_active_children
    root = create_menu_item
    child_one = create_menu_item(:parent => root, :is_active => true)
    create_menu_item(:parent => root, :is_active => false)
    active_children = root.active_children
    assert_equal [child_one], active_children
  end

  def test_should_be_able_to_have_page
    mi = create_menu_item
    mi.update_attributes :page => first_or_create(:page), :is_linkable => true
    assert_equal mi.page, first_or_create(:page)
    assert_equal mi.link, first_or_create(:page)
    assert_nil mi.url
    mi.update_attributes :is_linkable => false
    assert_equal mi.url, ""
    assert mi.page_id
  end

  def test_prioritze_page_over_url
    mi = create_menu_item
    mi.update_attributes :page => first_or_create(:page), :url => "http://www.google.com", :is_linkable => true
    assert_equal mi.page, first_or_create(:page)
    assert_equal mi.link, first_or_create(:page)
    assert_nil mi.url
    mi.update_attributes :page => nil, :url => "http://www.google.com", :is_linkable => true
    assert_equal "http://www.google.com", mi.url
    assert_equal "http://www.google.com", mi.link
    assert_nil mi.page_id
  end

  def test_should_clear_url_if_not_linkable
    mi = create_menu_item
    mi.update_attributes :url => "http://www.google.com", :is_linkable => true
    assert_equal "http://www.google.com", mi.url
    mi.update_attributes :is_linkable => false
    assert_equal "", mi.url
    assert_nil mi.page_id
  end

  def test_allow_key
    mi = create_menu_item
    mi.update_attributes :key => 'one_key'
    assert_equal "one_key", mi.key
    mi.update_attributes :key => nil
    assert_equal nil, mi.key
  end

  private

  def create_menu_item(options = {})
    default_options = {
      :caption => "Caption",
      :url => "http://www.gnuine.com",
      :description => "Gnuine webpage",
      :is_linkable => true,
      :parent_id => nil,
      :position => 0,
      :menu => Menu.first || Menu.create(:name => 'foo_menu')
    }
    MenuItem.create(default_options.merge(options))
  end
end
