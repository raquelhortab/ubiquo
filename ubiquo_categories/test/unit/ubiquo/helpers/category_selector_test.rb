require File.dirname(__FILE__) + "/../../../test_helper.rb"
require 'mocha'

class Ubiquo::Helpers::CategorySelectorTest < ActionView::TestCase

  include Ubiquo::Extensions::FiltersHelper
  include UbiquoCategories::Extensions::Helpers
  ActionView::Base.send :include, Ubiquo::Extensions::FiltersHelper

  connector = UbiquoCategories::Connectors::Base.current_connector
  ActionView::TestCase.send(:include, connector::UbiquoHelpers::Helper)
    
  def setup
    category_set = CategorySet.create(:name => "Tags", :key => "tags")
    category_set.categories.build(:name => "Red")
    category_set.categories.build(:name => "Blue")
    category_set.save
  end
  
#  def test_prints_selector_with_implicit_type
#    form_for(:post, CategoryTestModel.new) do |f|
#      concat f.category_selector(:tags, :type => 'checkbox')
#      concat f.category_selector(:tags, :type => 'select')
#    end
#
#    expected =
#      "<form>" + category_checkbox_output + category_select_output + "</form>"
#
#    assert_dom_equal expected, output_buffer
#  end
  
  def test_category_select_selector
#    require 'ruby-debug';debugger
  end

  def test_render_category_filter
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    CategorySet.create(:key => 'genres', :name => 'genres')
    assert_nothing_raised do
      assert render_category_filter('url', {:set => :genres})
    end
  end

  def test_render_category_filter_fails_when_set_does_not_exist
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    assert_raise UbiquoCategories::SetNotFoundError do
      render_category_filter 'url', {:set => :genres}
    end
  end

  def test_render_category_filter_loads_categories_from_set
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    ActionView::Base.any_instance.stubs(:link_to)
    set = CategorySet.create(:key => 'genres', :name => 'genres')
    CategorySet.expects(:find_by_key).with('genres').returns(set)
    CategorySet.any_instance.expects(:categories).returns(Category.all)
    render_category_filter({:aa => 'a'}, {:set => :genres})
  end

  def test_render_category_filter_prints_categories_from_set
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    ActionView::Base.any_instance.stubs(:link_to)
    set = CategorySet.create(:key => 'genres', :name => 'genres')
    set.categories << ['Male', 'Female']
    render_category_filter({:controller => 'a', :action => 'a'}, {:set => :genres})
  end

  def test_filter_category_info
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    CategorySet.create(:key => 'genres', :name => 'genres')
    assert_nothing_raised do
      filter_category_info('url', {:set => :genres})
    end
  end

  def test_filter_category_info_fails_when_set_does_not_exist
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    assert_raise UbiquoCategories::SetNotFoundError do
      filter_category_info 'url', {:set => :genres}
    end
  end

  def test_filter_category_info_loads_categories_from_set
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    set = CategorySet.create(:key => 'genres', :name => 'genres')
    CategorySet.expects(:find_by_key).with('genres').returns(set)
    CategorySet.any_instance.expects(:categories).returns(Category)
    filter_category_info 'url', {:set => :genres}
  end

  def test_filter_category_info_prints_categories_from_set
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    set = CategorySet.create(:key => 'genres', :name => 'genres')
    set.categories << ['Male', 'Female']
    filter_category_info 'url', {:set => :genres}
  end

  private
  
  def category_checkbox_output
    "checkboxes"
  end
  
  def category_select_output
    "<select id=\"post_tags\" name=\"post[tags]\">" +
    "<option value=\"Blue\">Blue</option>" +
    "<option value=\"Red\">Red</option>" +      
    "</select"
  end
end

create_categories_test_model_backend