require File.dirname(__FILE__) + '/../../../test_helper'

class GenericDetailWidgetUbiquoTest < ActionController::TestCase
  include TestSupport::UrlHelper
  tests Ubiquo::WidgetsController

  test "edit new form" do
    widget, page = create_widget(:generic_detail)
    get :show, :page_id => page.id, :id => widget.id
    assert_response :success
  end

  test "edit form" do
    widget, page = create_widget(:generic_detail)
    get :show,
        :page_id   => page.id,
        :id        => widget.id
    assert_response :success
  end

  test "form submit" do
    widget, page = create_widget(:generic_detail)
    xhr :post, :update, :page_id => page.id,
                        :id => widget.id,
                        :widget => widget_attributes
    assert_response :success
  end

  test "form submit with errors" do
    widget, page = create_widget(:generic_listing)
    xhr :post, :update, :page_id => page.id,
                        :id => widget.id,
                        :widget => {:model => ''}
    assert_response :success
    assert_select_rjs "error_messages"
  end

  private

  def widget_attributes
    {
      :model => 'Model'
    }
  end

  def create_widget(type, options = {})
    insert_widget_in_page(type, widget_attributes.merge(options))
  end

end
