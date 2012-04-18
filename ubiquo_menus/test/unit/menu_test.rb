# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/../test_helper.rb"

class MenuTest < ActiveSupport::TestCase
  def test_should_create_menu
    assert_difference 'Menu.count' do
      menu = create(:menu)
      assert !menu.new_record?, "#{menu.errors.full_messages.to_sentence}"
    end
  end

  def test_should_return_menu_items
    item1, item2 = [create_menu_item(:caption => 'caption1', :parent_id => nil),
      create_menu_item(:caption => 'caption2', :parent_id => nil)]
    menu = create(:menu)
    menu.menu_items = [item1, item2]
    assert menu.save
    assert !menu.new_record?, "#{menu.errors.full_messages.to_sentence}"
    assert_equal [item1, item2], menu.menu_items
  end

  def test_should_have_menu_items
    menu = create(:menu)
    menu.menu_items = [item = new_menu_item]
    assert !item.new_record?
    assert_equal menu.menu_items, [item]
  end

  def test_should_support_menu_items_with_nested_attributes
    menu = create(:menu)
    url, caption = ['my_url', 'caption']
    menu.menu_items_attributes = [{:url => url, :caption => caption}]
    assert menu.save
    assert item = MenuItem.last
    assert_equal menu, item.menu
    assert_equal [item], menu.menu_items
  end

  def test_should_support_the_destroyal_of_menu_items_using_nested_attributes_via_destroy_flag
    menu = create(:menu)
    url, caption = ['my_url', 'caption']
    menu.menu_items_attributes = [{:url => url, :caption => caption}]
    assert menu.save
    assert item = MenuItem.last
    assert_equal [item], menu.menu_items

    menu.menu_items_attributes = [{:url => url, :caption => caption, :id => item.id, :_destroy => true}]
    assert menu.save
    assert !MenuItem.find_by_id(item.id)
    assert menu.menu_items.blank?
  end

  def test_should_support_the_destroyal_of_menu_items_using_nested_attributes_via_blank_attributes
    menu = create(:menu)
    url, caption = ['my_url', 'caption']
    menu.menu_items_attributes = [
      { :url => url, :caption => caption },
      { :url => '',  :caption => ''      },
    ]
    assert menu.save
    assert item = MenuItem.last
    assert_equal [item], menu.menu_items
  end

  def test_should_support_the_destroyal_of_menu_items_using_nested_attributes_via_destroy_flag_in_creation
    menu = create(:menu)
    url, caption = ['my_url', 'caption']
    menu.menu_items_attributes = [
      { :url => url, :caption => caption },
      { :url => url, :caption => caption, :_destroy => true },
    ]
    assert menu.save
    assert item = MenuItem.last
    assert_equal [item], menu.menu_items
  end

  def test_should_support_the_destroyal_of_menu_items_using_nested_attributes_via_blank_attributes_in_creation
    menu = create(:menu)
    menu.menu_items_attributes = [{:url => '', :caption => '', :_destroy => false}]
    assert menu.menu_items.blank?
  end

  def test_children_alias_method
    menu = create(:menu)
    url, caption = ['my_url', 'caption']
    menu.menu_items_attributes = [{:url => url, :caption => caption}]
    assert menu.save
    assert item = MenuItem.last
    assert_equal [item], menu.menu_items
    assert_equal menu.menu_items, menu.children
  end

  def test_should_require_name
    menu = Menu.new(:name => "")
    assert !menu.valid?
    assert menu.errors.include?(:name)

    menu.name = 'my name'
    assert menu.valid?
    assert !menu.errors.include?(:name)
  end

  def test_should_generate_key
    assert_difference 'Menu.count' do
      menu = create(:menu, :name => "GENERATE KEY", :key => nil)
      assert !menu.new_record?, "#{menu.errors.full_messages.to_sentence}"
      assert_equal nil, menu.key
    end

    assert_difference 'Menu.count' do
      menu = create(:menu, :name => "GENERATE KEY", :key => nil, :force_key => true)
      assert !menu.new_record?, "#{menu.errors.full_messages.to_sentence}"
      assert_equal "GENERATE KEY".parameterize.underscore.to_s, menu.key
    end
  end

  def test_should_update_positions_on_save
    menu = create(:menu)
    menu.menu_items_attributes = [
      { :url => '1', :caption => '1' },
      { :url => '2', :caption => '2' },
      { :url => '3', :caption => '3' },
      { :url => '4', :caption => '4' },
      { :url => '5', :caption => '5' },
      { :url => '6', :caption => '6' },
    ]
    assert menu.save
    assert_equal 6, menu.menu_items.size
    (0..5).each do |n|
      item = menu.menu_items[n]
      assert_equal n + 1, item.position
      assert_equal item.caption.to_i, item.position
    end
    assert menu.update_attributes({
      :menu_items_attributes => 5.downto(0).map do |n|
        item = menu.menu_items[n]
        {
          :id       => item.id,
          :url      => item.url,
          :caption  => item.caption,
        }
      end
    }, :as => :admin)
    5.downto(0).each do |n|
      item = menu.menu_items[n]
      assert_equal n + 1, item.position
      assert_equal item.caption.to_i, item.position
    end

    menu.reload
    menu.expects(:update_positions!)
    menu.save
  end

  def test_should_get_menus_filtered_by_name
    Menu.delete_all
    menu1 = create(:menu, :name => 'should_fínd_d1')
    menu2 = create(:menu, :name => 'should_finD_d2')
    menu3 = create(:menu, :name => 'not_found')
    assert_equal [menu1, menu2], Menu.filtered_search("filter_text" => 'find')
  end

  def test_should_get_menus_filtered_by_key
    Menu.delete_all
    menu1 = create(:menu, :key => 'should_fínd_1')
    menu2 = create(:menu, :key => 'should_finD_2')
    menu3 = create(:menu, :key => 'not_found')
    assert_equal [menu1, menu2], Menu.filtered_search("filter_text" => 'find')
  end



  def test_should_return_menu_items_in_order
    menu = create(:menu)
    item1, item2, item3 = [
      create_menu_item(:caption => 'caption1', :parent_id => nil, :position => 2, :menu => menu),
      create_menu_item(:caption => 'caption2', :parent_id => nil, :position => 1, :menu => menu),
      create_menu_item(:caption => 'caption3', :parent_id => nil, :position => 3, :menu => menu)
    ]

    menu.reload
    assert_equal [item2, item1, item3], menu.menu_items

    item2.destroy
    menu.reload
    assert_equal [item1, item3], menu.menu_items

    assert_equal [2, 3], menu.menu_items.map(&:position)
    assert menu.save
    assert_equal [1, 2], menu.menu_items.map(&:position)
  end

  def test_should_update_positions_after_save
    menu = create(:menu)
    assert !menu.new_record?, "#{menu.errors.full_messages.to_sentence}"
    menu.expects(:update_positions!)
    assert menu.save
  end

  def test_should_accept_nested_attributes_for_menu_items
    attributes = {"menu_items_attributes"=> {
        "1"=> menu_item_attributes,
        "2"=> menu_item_attributes
      }
    }
    menu = create(:menu, attributes)
    assert_equal 2, menu.menu_items.count
  end

  def test_should_discard_empty_menu_items_attributes
    attributes = {"menu_items_attributes"=> {
        "1"=> menu_item_attributes(:caption => '', :url => ''),
        "2"=> menu_item_attributes
      }
    }
    menu = create(:menu, attributes)
    assert_equal 1, menu.menu_items.count
  end

  def test_should_not_lose_menu_items_if_one_fails
    attributes = {"menu_items_attributes"=> {
        "1"=> menu_item_attributes(:url => ''),
        "2"=> menu_item_attributes
      }
    }
    menu = create(:menu, attributes)
    assert_equal 2, menu.menu_items.select{|item| item.new_record?}.size
  end

  def test_should_set_correct_positions_when_creating
    attributes = {
      "menu_items_attributes"=> [
        menu_item_attributes,
        menu_item_attributes,
      ]
    }
    menu = create(:menu, attributes)
    assert !menu.new_record?
    assert_equal [1,2], menu.menu_items.map(&:position)
  end

  private

  def create_menu_item(options = {})
    menu = new_menu_item(options)
    assert menu.save
    menu
  end

  def new_menu_item(options = {})
    MenuItem.new(menu_item_attributes(options))
  end

  def menu_item_attributes(options = {})
    {
      :is_linkable => true,
      :url => "http://www.gnuine.com",
      :caption => "Caption",
      :parent_id => nil,
      :nested => true
    }.merge(options)
  end

end
