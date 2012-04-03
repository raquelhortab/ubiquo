require File.dirname(__FILE__) + "/../../test_helper.rb"

class Ubiquo::WidgetsControllerTest < ActionController::TestCase
  # use_ubiquo_fixtures
  include TestSupport::UrlHelper

  def test_should_add_widget_through_html
    assert_difference('Widget.count') do
      post :create, :page_id => pages(:one_design).id, :block => pages(:one_design).blocks.first, :widget => widgets(:one).class.to_s
    end
    assert_redirected_to(ubiquo.page_design_path(pages(:one_design)))
    widget = assigns(:widget)
    assert_not_nil widget
    assert_equal widget.block, pages(:one_design).blocks.first
    assert_equal widget.key, widgets(:one).key
    assert_equal widget.name, Widget.default_name_for(widgets(:one).key)
  end

  def test_should_add_editable_widget_through_js
    widgets = pages(:one_design).available_widgets - [:global]
    editable_widget = widgets.select do |widget_key|
      Widget.class_by_key(widget_key).is_configurable?
    end.first
    assert_not_nil editable_widget
    assert_difference('Widget.count') do
      xhr :post, :create, :page_id => pages(:one_design).id, :block => pages(:one_design).blocks.first, :widget => editable_widget.to_s
    end
    widget = assigns(:widget)
    assert_not_nil widget
    assert widget.block == pages(:one_design).blocks.first
    assert_equal widget.key, editable_widget
    assert_select_rjs :insert_html, "block_type_holder_#{widget.block.block_type}" do
      assert_select "#widget_#{widget.id}"
    end
    assert_match /myLightWindow\._processLink\(\$\(\'edit_widget_#{widget.id}\'\)\)\;/, @response.body
  end

  def test_should_destroy_widget_through_html
    assert_difference('Widget.count',-1) do
      delete :destroy, :page_id => pages(:one_design).id, :id => widgets(:one)
    end
    assert_redirected_to(ubiquo.page_design_path(pages(:one_design)))
  end

  def test_should_destroy_widget_through_js
    assert_difference('Widget.count',-1) do
      xhr :post, :destroy, :page_id => pages(:one_design).id, :id => widgets(:one)
    end
    assert_select_rjs :remove, "widget_#{widgets(:one).id}"
  end

  def test_should_show_widget_form
    widget_form_mock
    get :show, :page_id => pages(:one_design).id, :id => widgets(:one)
    assert_response :success

    assert_not_nil widget = assigns(:widget)
    assert_not_nil page = assigns(:page)
  end

  def test_should_edit_widget_throught_js
    xhr :put, :update, :page_id => pages(:one_design).id, :id => widgets(:one).id, :widget => {:name => "Test name", :content => "Test content"}

    assert_not_nil widget = assigns(:widget)
    assert_equal widget.reload.name, "Test name"
    assert_equal widget.content, "Test content"
  end

  def test_should_change_order
    block = pages(:one_design).all_blocks_as_hash['sidebar']
    Widget.update_all ["block_id = ?", block.id]
    assert_operator block.widgets.size, :>, 1
    original = block.widgets.map(&:id)

    get :change_order, :page_id => pages(:one_design).id, "block" => {block.block_type => original.reverse}
    assert_equal original.reverse, block.reload.widgets.map(&:id)
    assert_redirected_to(ubiquo.page_design_path(pages(:one_design)))
  end

  def test_should_change_order_with_empty_blocks
    get :change_order, :page_id => pages(:one_design).id
    assert_redirected_to(ubiquo.page_design_path(pages(:one_design)))
  end

  def test_should_change_name
    xhr :post, :change_name, :page_id => pages(:one_design).id, :id => widgets(:one).id, :value => "New name"
    assert_not_nil widget = assigns(:widget)
    assert_response :success
    assert_equal widget.name, "New name"
  end

end
