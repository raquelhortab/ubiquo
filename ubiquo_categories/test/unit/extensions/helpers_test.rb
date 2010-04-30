require File.dirname(__FILE__) + "/../../test_helper.rb"

class UbiquoCategories::Extensions::HelpersTest < ActionView::TestCase

  include Ubiquo::Extensions::FiltersHelper
  include UbiquoCategories::Extensions::Helpers
  ActionView::Base.send :include, Ubiquo::Extensions::FiltersHelper

  connector = UbiquoCategories::Connectors::Base.current_connector
  ActionView::TestCase.send(:include, connector::UbiquoHelpers::Helper)

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

end

create_categories_test_model_backend