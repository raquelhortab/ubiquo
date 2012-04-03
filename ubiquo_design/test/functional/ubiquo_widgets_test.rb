require File.dirname(__FILE__) + '/../test_helper'

class GenericDetailWidgetTest < ActionController::TestCase
  include TestSupport::UrlHelper
  tests PagesController

  test "should render" do
    widget, page = create_widget(:generic_detail)
    old_proc_behaviour = ::Widget.behaviours[widget.key][:proc]

    begin
      ::Widget.behaviours[widget.key][:proc] = Proc.new do |*|
        render :text => "<div id=\"widget-test-container\">Foo</div>"
      end

      get :show, :url => [page.url_name, widget.id]

      assert @controller.widget_performed?
      assert @controller.widget_rendered?
      assert !@controller.widget_redirected?
      assert_select "#widget-test-container", "Foo"

    ensure
      ::Widget.behaviours[widget.key][:proc] = old_proc_behaviour
    end
  end

  test "should redirect" do
    widget, page = create_widget(:generic_detail)
    old_proc_behaviour = ::Widget.behaviours[widget.key][:proc]

    begin
      ::Widget.behaviours[widget.key][:proc] = Proc.new do |*|
        redirect_to 'http://www.google.com'
      end

      get :show, :url => [page.url_name, widget.id]

      assert @controller.widget_performed?
      assert @controller.widget_redirected?

    ensure
      ::Widget.behaviours[widget.key][:proc] = old_proc_behaviour
    end
  end

  private

  def widget_attributes
    {
      :model => 'GenericDetail'
    }
  end

  def create_widget(type, options = {})
    insert_widget_in_page(type, widget_attributes.merge(options))
  end

end
