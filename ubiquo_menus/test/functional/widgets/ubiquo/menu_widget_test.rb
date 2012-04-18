require File.dirname(__FILE__) + '/../../../test_helper'

class MenuWidgetUbiquoTest < ActionController::TestCase
  tests Ubiquo::WidgetsController

  test "edit new form" do
    widget, page = create_widget(:menu_widget)
    get :show, :page_id => page.id, :id => widget.id
    assert_response :success
  end

  test "edit form" do
    widget, page = create_widget(:menu_widget)
    get :show, :page_id => page.id, :id => widget.id
    assert_response :success
  end

  test "form submit" do
    widget, page = create_widget(:menu_widget)
    xhr :post, :update, :page_id => page.id,
                        :id => widget.id,
                        :widget => widget_attributes
    assert_response :success
  end

  # Uncomment if it is a configurable widget, otherwise it should never return errors
  #test "form submit with errors" do
  #  login_as
  #  widget, page = create_widget(:menu_widget)
  #  xhr :post, :update, :page_id => page.id,
  #                      :id => widget.id,
  #                      :widget => {}
  #  assert_response :success
  #  assert_select_rjs "error_messages"
  #end

  private

  def widget_attributes
    {
      :menu_id => create_menu.id
    }
  end

  def create_widget(type, options = {})
    insert_widget_in_page(type, widget_attributes.merge(options))
  end

  def create_menu(options = {})
    default_options = {
      :name => "Test Menu",
    }
    Menu.create(default_options.merge(options))
  end

end
