require File.dirname(__FILE__) + '/../../test_helper'

class MenuWidgetWidgetTest < ActionController::TestCase
  tests PagesController

  test "menu_widget widget should get show" do
    widget, page = create_widget(:menu_widget)
    get :show, :url => page.url_name
    assert_response :success
    #assert_equal widget_attributes[:title], assigns(:title), "Error on widget title"
  end

  test "menu_widget widget view should be as expected" do
    widget, page = create_widget(:menu_widget)
    get :show, :url => page.url_name
    # Test the view here
    # assert_select "div.xxx" do
    # end
  end

  private

  def widget_attributes
    {
      :menu_id => create_menu.id
    }  
  end

  def create_menu(options = {})
    default_options = {
      :name => "Test Menu",
    }
    Menu.create(default_options.merge(options))
  end
  
  def create_widget(type, options = {})
    insert_widget_in_page(type, widget_attributes.merge(options))
  end

end
