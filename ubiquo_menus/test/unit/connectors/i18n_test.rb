require File.dirname(__FILE__) + "/../../test_helper.rb"

class UbiquoMenus::Connectors::I18nTest < ActiveSupport::TestCase

  fixtures :menus, :menu_items

  if Ubiquo::Plugin.registered[:ubiquo_i18n]
    def setup
      save_current_menus_connector
      UbiquoMenus::Connectors::I18n.load!
    end

    def teardown
      reload_old_menus_connector
      Locale.current = nil
    end

    test "Menu and menu items are translatable" do
      assert Menu.is_translatable?
      assert MenuItem.is_translatable?
    end

    test "create menu and menu items migration" do
      ActiveRecord::Migration.expects(:create_table).with(:menu_items, :translatable => true).once
      ActiveRecord::Migration.expects(:create_table).with(:menus, :translatable => true).once
      ActiveRecord::Migration.uhook_create_menus_table
      ActiveRecord::Migration.uhook_create_menu_items_table
    end

    def test_copy_data_on_translate
      mi = create_menu_item
      mi.update_attribute :position, 5
      translation = mi.translate('ca_ES')
      translation.save
      assert !mi.new_record?
      assert !translation.new_record?
      assert_equal 5, mi.position
      assert_equal 5, translation.position
    end

    def test_should_require_unique_key_in_menus
      assert_difference 'Menu.count', 1 do
        menu = create_menu :key=> 'my_key'
        menu = create_menu :key=> menu.key
        assert menu.errors.on(:key)
        menu = create_menu :key=> menu.key.upcase
        assert menu.errors.on(:key)
      end
    end

    def test_has_translation_menu_items_after_create
      Locale.current = 'es'
      original = create_menu(:locale => 'es')
      assert !original.new_record?

      mi = create_menu_item(:menu => original, :locale => 'es')

      original.reload

      Locale.current = 'ca'
      translation = Menu.create({
        :content_id             => original.content_id,
        :locale                 => 'ca',
        :name                   => 'name',
        :menu_items_attributes  => [{ "id" => mi.id }]
      })
      assert !translation.new_record?
      assert_equal [mi], Menu.last.menu_items
      assert_equal mi, MenuItem.last
    end
  end

  private

  def create_menu_item(options = {})
    default_options = {
      :locale => 'es_ES',
      :caption => "Caption",
      :url => "http://www.gnuine.com",
      :description => "Gnuine webpage",
      :is_linkable => true,
      :parent_id => nil,
      :position => 0,
      :menu => Menu.create(:name => "foo_menu #{Time.now.to_i}",
                            :locale => 'es_ES'
                          )
    }
    MenuItem.create(default_options.merge(options))
  end

  def create_menu(options = {})
    default_options = {
      :name => "Test Menu",
    }
    Menu.create(default_options.merge(options))
  end

  def save_current_menus_connector
    @old_connector = UbiquoMenus::Connectors::Base.current_connector
  end

  def reload_old_menus_connector
    @old_connector.load!
  end
end
