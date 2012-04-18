require File.dirname(__FILE__) + '/../../test_helper'

class MenuWidgetTest < ActiveSupport::TestCase

  def test_should_create_menu_widget
    assert_difference 'MenuWidget.count' do
      menu_widget = create_menu_widget
      assert !menu_widget.new_record?, "#{menu_widget.errors.full_messages.to_sentence}"
    end
  end

  private

  def create_menu_widget(options = {})
    default_options = {
      :name => "Test menu_widget",
      :block => first_or_create(:block),
      :menu_id => (Menu.first || create_menu).id
      # Insert other options for widget here
    }
    MenuWidget.create(default_options.merge(options))
  end

  def create_menu(options = {})
    default_options = {
      :name => "Test Menu",
    }
    Menu.create(default_options.merge(options))
  end
end
