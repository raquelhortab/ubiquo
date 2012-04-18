require File.dirname(__FILE__) + "/../../test_helper.rb"

module Connectors
  class StandardTest < ActiveSupport::TestCase

    def setup
      save_current_menus_connector
      UbiquoMenus::Connectors::Standard.load!
    end

    def teardown
      reload_old_menus_connector
    end

    test "menu_items_controller find menu items" do
      menu = create_menu(:name => 'another')
      item1 = create_menu_item(:menu => menu)
      item2 = create_menu_item(:menu => menu)
      item3 = create_menu_item(:parent_id => item1.id, :menu => menu)
      menu.menu_items << item1
      menu.menu_items << item2
      menu.menu_items << item3
      menu.save
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {:menu_id => menu.id})
      assert_equal_set [item1,item2,item3], Ubiquo::MenuItemsController.new.uhook_find_menu_items
    end

    test "menu_items_controller new menu item without parent" do
      menu = Menu.first || create_menu
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {:menu_id => menu.id})
      mi = Ubiquo::MenuItemsController.new.uhook_new_menu_item
      assert_nil mi.parent_id
      assert mi.new_record?
    end

    test "menu_items_controller new menu item with parent" do
      menu = create_menu(:key => 'menu_items_controller_new',
                          :name => 'menu_items_controller_new'
                          )

      menu.menu_items << create_menu_item(:menu => menu)
      menu.save
      options = {
        :parent_id => menu.menu_items.first.id,
        :menu_id => menu.id
      }
      Ubiquo::MenuItemsController.any_instance.stubs(:params => options)
      mi = Ubiquo::MenuItemsController.new.uhook_new_menu_item
      assert_equal menu.menu_items.first.id, mi.parent_id
      assert mi.new_record?
    end

    test "menu_items_controller create menu item" do
      options = {
        :caption => "Caption",
        :url => "http://www.gnuine.com",
        :description => "Gnuine webpage",
        :is_linkable => true,
        :parent_id => nil,
        :position => 0,
        :menu => Menu.first || create_menu
      }
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {:menu_item => options})
      assert_difference "MenuItem.count" do
        mi = Ubiquo::MenuItemsController.new.uhook_create_menu_item
      end
    end

    test "menu_items_controller destroy menu item" do
      mi = create_menu_item
      assert_difference "MenuItem.count", -1*(1+mi.children.size) do
        Ubiquo::MenuItemsController.new.uhook_destroy_menu_item(mi)
      end
    end

    test "create menu items migration" do
      ActiveRecord::Migration.expects(:create_table).with(:menu_items).once
      ActiveRecord::Migration.uhook_create_menu_items_table
    end

    test "menus_controller find menus" do
      Ubiquo::MenusController.any_instance.stubs(:params => {})
      menu = Menu.first || create_menu
      assert_equal_set Menu.all, Ubiquo::MenusController.new.uhook_find_menus[1]
    end

    test "menu_items_controller create menu" do
      options = {
        :key => "menu_foo_new",
        :name => "Menu foo new",
      }
      Ubiquo::MenusController.any_instance.stubs(:params => {:menu => options})
      assert_difference "Menu.count" do
        mi = Ubiquo::MenusController.new.uhook_create_menu
      end
    end

    test "menu_controller destroy menu" do
      m = Menu.first || create_menu
      assert_difference "Menu.count", -1 do
        Ubiquo::MenusController.new.uhook_destroy_menu(m)
      end
    end

    test "create menu migration" do
      ActiveRecord::Migration.expects(:create_table).with(:menus).once
      ActiveRecord::Migration.uhook_create_menus_table
    end

    test "should require unique key in menus" do
      assert_difference 'Menu.count', 1 do
        menu = create_menu :key=> 'my_key'
        menu = create_menu :key=> menu.key
        assert menu.errors.include?(:key)
        menu = create_menu :key=> menu.key.upcase
        assert menu.errors.include?(:key)
      end
    end

    protected
    def create_menu(options = {})
      default_options = {
        :name => "Test Menu item",
      }
      Menu.create(default_options.merge(options))
    end
    def create_menu_item(options = {})
      default_options = {
        :caption => "Caption",
        :url => "http://www.gnuine.com",
        :description => "Gnuine webpage",
        :is_linkable => true,
        :parent_id => nil,
        :position => 0,
        :menu => Menu.first || create_menu
      }
      MenuItem.create(default_options.merge(options))
    end

    def save_current_menus_connector
      @old_connector = UbiquoMenus::Connectors::Base.current_connector
    end

    def reload_old_menus_connector
      @old_connector.load!
    end

  end
end
