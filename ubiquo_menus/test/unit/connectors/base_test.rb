require File.dirname(__FILE__) + "/../../test_helper.rb"

module Connectors
  class BaseTest < ActiveSupport::TestCase

    test "find menu items returns all menu item" do
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {:menu_id => create_menu.id}, :session => {})
      Ubiquo::MenuItemsController.new.uhook_find_menu_items.each do |mi|
        assert mi.is_a?(MenuItem)
      end
    end

    test "find menus returns all menus" do
      Ubiquo::MenusController.any_instance.stubs(:params => {}, :session => {})
      Ubiquo::MenusController.new.uhook_find_menus[1].each do |mi|
        assert mi.is_a?(Menu)
      end
    end

    protected

    def create_menu_item(options = {})
      default_options = {
        :caption => "Caption",
        :url => "http://www.gnuine.com",
        :description => "Gnuine webpage",
        :is_linkable => true,
        :parent_id => nil,
        :position => 0,
      }
      MenuItem.create(default_options.merge(options))
    end

    def create_menu(options = {})
      default_options = {
        :name => "Test Menu",
      }
      Menu.create(default_options.merge(options))
    end
  end
end
