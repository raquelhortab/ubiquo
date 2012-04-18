require File.dirname(__FILE__) + "/../../test_helper.rb"

class Ubiquo::MenusControllerTest < ActionController::TestCase

  include TestSupport::UrlHelper

  def test_should_get_index

    get :index
    assert_response :success
    assert_not_nil assigns(:menus)
  end

  def test_should_get_index_in_json_format

    create_menu
    get :index, :format => 'json'
    assert_response :success
    assert_not_nil menus = assigns(:menus)
    assert_equal ActiveSupport::JSON.decode(menus.to_json(:only => [:name,:id])), ActiveSupport::JSON.decode(@response.body)
  end

  def test_should_not_get_new_button

    create_menu
    Ubiquo::Settings.context(:ubiquo_menus).set(:allow_create, false)
    get :index
    assert_response :success
    assert_select "#sidebar a.new", 0
  end

  def test_should_get_new_button

    create_menu
    Ubiquo::Settings.context(:ubiquo_menus).set(:allow_create, true)
    get :index
    assert_response :success
    assert_select "#sidebar a.new", 1
  end

  def test_should_get_new

    get :new
    assert_response :success
  end

  def test_should_create_menu

    assert_difference('Menu.count') do
      post :create, :menu => menu_attributes
    end

    assert_response :redirect
  end

  def test_should_get_edit

    get :edit, :id => (Menu.first || create_menu).id
    assert_response :success
  end

  def test_should_update_menu

    menu = menu_attributes.merge(:name => 'new_caption')
    put :update, :id =>  (Menu.first || create_menu).id, :menu => menu
    assert_redirected_to ubiquo.menus_path
  end

  def test_should_destroy_menu

    mi = Menu.first || create_menu
    assert_difference('Menu.count', -1) do
      delete :destroy, :id => mi.id
    end

    assert_redirected_to ubiquo.menus_path
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
    }
    MenuItem.create(default_options.merge(options))
  end

  def create_menu(options = {})
    Menu.create(menu_attributes(options))
  end

  def menu_attributes(options = {})
    default_options = {
      :name => "Caption",
      :key => "hwwwgnuinecom",
    }
    default_options.merge(options)
  end


end
