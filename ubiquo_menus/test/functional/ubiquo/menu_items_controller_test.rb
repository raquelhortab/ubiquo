require File.dirname(__FILE__) + "/../../test_helper.rb"

class Ubiquo::MenuItemsControllerTest < ActionController::TestCase

  include TestSupport::UrlHelper

  def test_should_get_index_in_js_format

    get :index, :menu_id => (Menu.first || create_menu).id, :format => 'js'
    assert_response :success
    assert_not_nil menu_items = assigns(:menu_items)
    assert_equal ActiveSupport::JSON.decode(menu_items.to_json(:only => [:caption,:id])), ActiveSupport::JSON.decode(@response.body)
  end

  def test_should_create_menu_item

    assert_difference('MenuItem.count') do
      post :create, :menu_item => menu_item_attributes, :menu_id => (Menu.first || create_menu).id
    end

    assert_redirected_to ubiquo.edit_menu_path(Menu.first)
  end

  def test_should_get_edit

    get :edit, :id => create_menu_item.id, :menu_id => (Menu.first || create_menu).id
    assert_response :success
  end

  def test_should_update_menu_item

    menu_item = create_menu_item(:caption => 'caption')
    put :update, :id => menu_item.id, :menu_item => {:caption => 'new_caption'}, :menu_id => menu_item.menu_id
    assert_redirected_to ubiquo.edit_menu_path(menu_item.menu)
    assert_equal 'new_caption', menu_item.reload.caption
  end

  def test_should_destroy_menu_item

    mi = create_menu_item
    assert_difference('MenuItem.count', -1*(1+mi.children.size)) do
      delete :destroy, :id => mi.id, :menu_id => mi.menu_id
    end

    assert_redirected_to ubiquo.edit_menu_path(Menu.first)
  end

  def test_should_set_parent_id_on_new

    m = create_menu_item
    get :new, {:parent_id => m.id, :menu_id =>  m.menu_id}
    assert_response :success
    assert_select("input#menu_item_parent_id", 1, "Cannot find parent_id on new menu_item")
    assert_select("input#menu_item_parent_id[value=\"#{m.id}\"]", 1,
      "Cannot find expected parent_id on new menu_item")
  end

  def test_should_be_sortable

    root1 = create_menu_item(:caption => 'caption1')
    child11 = create_menu_item(:caption => 'caption11', :parent_id => root1.id)
    child12 = create_menu_item(:caption => 'caption12', :parent_id => root1.id)
    new_order = [child12, child11].map(&:id)
    xhr :put, :update_positions, {:menu_items_list => new_order, :column => 'menu_items_list', :menu_id => root1.menu_id, :id => root1.id  }
    assert_response :success
    assert_equal root1.children.map(&:id), new_order
  end

  private

  def create_menu_item(options = {})
    MenuItem.create(menu_item_attributes(options))
  end

  def menu_item_attributes(options = {})
    default_options = {
      :caption => "Caption",
      :url => "http://www.gnuine.com",
      :description => "Gnuine webpage",
      :is_linkable => true,
      :parent_id => nil,
      :position => 0,
      :menu_id => (Menu.first || create_menu).id
    }
    default_options.merge(options)
  end

  def create_menu(options = {})
    Menu.create(menu_attributes(options))
  end

  def menu_attributes(options = {})
    default_options = {
      :name => "name",
      :key => "key",
    }
    default_options.merge(options)
  end

end
