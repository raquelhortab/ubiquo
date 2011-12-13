# -*- coding: undecided -*-
require File.dirname(__FILE__) + "/../../test_helper.rb"
require 'ubiquo_categories/filters/category_filter'

class CategoryFilterTest < Ubiquo::Filters::UbiquoFilterTestCase

  include UbiquoCategories::Extensions::Helpers

  connector = UbiquoCategories::Connectors::Base.current_connector
  Ubiquo::Filters::FakeContext.send(:include, connector::UbiquoHelpers::Helper)

  def setup
    self.stubs(:params).returns({})
    self.stubs(:current_locale).returns('ca')
    @set = create_set :genres
    @filter = CategoryFilter.new(@model, @context)
  end

  def test_render_category_filter
    assert_nothing_raised do
     assert @filter.configure(:genres, :url_for_options => 'url')
    end
  end

  def test_render_category_filter_fails_when_set_does_not_exist
    assert_raise UbiquoCategories::SetNotFoundError do
      @filter.configure(:unknown, :url_for_options => 'url')
      @filter.render
    end
  end

  def test_render_category_filter_loads_categories_from_set
    CategorySet.expects(:find_by_key).with('genres').returns(@set)
    CategorySet.any_instance.expects(:categories).returns(Category.all)
    @filter.configure(:genres, :url_for_options => { :aa => 'a' })
    assert_match /MyString/, @filter.render
  end

  def test_render_category_filter_prints_categories_from_set
    @set.categories << ['Male', 'Female']
    @filter.configure(:genres, :url_for_options => { :controller => 'a', :action => 'a'})
    rendered_filter = @filter.render
    @set.categories do |category|
      assert_match /#{category}/, rendered_filter
    end
  end

  def test_filter_category_message
    assert_nothing_raised do
      @filter.configure(:genres, :url_for_options => 'url')
      @filter.message
    end
  end

  def test_filter_category_message_fails_when_set_does_not_exist
    assert_raise UbiquoCategories::SetNotFoundError do
      @filter.configure(:unknown, :url_for_options => 'url')
      @filter.message
    end
  end

  def test_filter_category_info_loads_categories_from_set
    CategorySet.expects(:find_by_key).with('genres').returns(@set)
    @set.categories << ['Male', 'Female']
    categories = @set.categories
    CategorySet.any_instance.expects(:categories).returns(categories)

    @context.params.merge!({'filter_genres' => 'Male'})
    @filter.configure(:genres, :url_for_options => 'url')
    assert_match /Male/, @filter.message.first
  end

  def test_filter_categories_for_select_should_use_connector_uhook
    mock = mock("Object")
    @filter.expects(:category_set).with('some_key').returns(mock)
    @context.expects(:uhook_categories_for_set).with(mock)

    @filter.send(:categories_for_select, 'some_key')
  end

  def test_filter_category_set
    CategorySet.expects(:find_by_key).with('some_keys').returns(true)
    @filter.send(:category_set, 'some_key')
  end

  def test_filter_category_set_should_raise_and_exception_if_the_set_can_not_not_found
    CategorySet.expects(:find_by_key).with('some_keys').returns(false)
    assert_raises(UbiquoCategories::SetNotFoundError) do
      @filter.send(:category_set, 'some_key')
    end
  end

end

create_categories_test_model_backend
