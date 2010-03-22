require File.dirname(__FILE__) + "/../../test_helper.rb"
require 'mocha'

class UbiquoCategories::ActiveRecordTest < ActiveSupport::TestCase
  use_ubiquo_fixtures
  
  def test_categorized_with
    assert_nothing_raised do
      CategoryTestModel.class_eval do
        categorized_with :city
      end
    end
  end

  def test_categorized_creates_assignation_method
    categorize :city
    assert_nothing_raised do
      model = create_category_model
      model.city = 'City'
    end
  end

  def test_categorized_creates_retrieval_method
    categorize :city
    assert_nothing_raised do
      model = create_category_model
      model.city
    end
  end

  def test_categorized_stores_and_returns_category
    categorize :city
    model = create_category_model
    model.city = 'City'
    assert_equal 'City', model.city.to_s
    assert_equal Category, model.city.class
  end

  def test_categorized_creates_has_many_category_relations
    categorize :city
    model = create_category_model
    assert_nothing_raised do
      assert_equal [], model.category_relations
    end
  end

  def test_categorized_with_defaults_to_size_1
    categorize :city
    assert_raise UbiquoCategories::LimitError do
      model = create_category_model
      model.city = 'City1##City2'
    end
  end

  def test_categorized_store_one_string_element
    categorize :city
    model = create_category_model
    model.city = 'City'
    assert_kind_of Category, model.city
    assert_equal 1, model.category_relations.size
  end

  def test_categorized_store_many_string_elements
    categorize :cities, :size => :many
    model = create_category_model
    model.city = 'City1##City2'
    assert_kind_of Array, model.cities
    assert_equal 2, model.category_relations.size
    assert_equal 'City1', model.cities.first.to_s
    assert_equal 'City2', model.cities.last.to_s
  end

  def test_categorized_store_many_string_elements_with_different_separator
    categorize :cities, :size => :many, :separator => '-'
    model = create_category_model
    model.cities = 'City1-City2'
    assert_kind_of Array, model.cities
    assert_equal 2, model.category_relations.size
    assert_equal 'City1', model.cities.first.to_s
    assert_equal 'City2', model.cities.last.to_s
  end

  def test_categorized_uses_category_set_pluralizing_name
    categorize :city
    categorize :cities, :size => :many
    model = create_category_model
    CategorySet.expects('find_by_key').with('cities').times(2).returns(category_sets(:cities))
    model.city = 'city' # pluralizes city to cities
    model.cities = 'city' # maintains cities
  end

#  def test_categorized_creates_category_inside_proper_set
#    categorize :city
#    set = category_sets(:cities)
#    set.allow_creation!
#    assert_equal [], set.categories
#    assert_difference 'CategorySet.count', 2 do
#      model = create_category_model
#      model.cities = 'Barcelona##Athens'
#    end
#    assert_equal 2, set.reload.categories.count
#  end
#
#  def test_categorized_retrieves_category_inside_proper_set
#    categorize :city
#    set = category_sets(:cities)
#    set.allow_creation!
#    set.categories = Category.create(:name => 'Barcelona'), Category.create(:name => 'Athens')
#    assert_equal [], set.categories
#    assert_no_difference 'CategorySet.count' do
#      model = create_category_model
#      model.cities = 'Barcelona##Athens'
#    end
#    assert_equal set, model.cities.first.category_set
#    assert_equal 2, set.reload.categories.count
#  end

  def test_should_raise_if_set_does_not_exist
    categorize :unknown
    model = create_category_model
    assert_raise UbiquoCategories::SetNotFoundError do
      model.unknown = 'tag'
    end
  end

  def test_assignation_accepts_strings_and_category_instances
    categorize :cities, :size => :many
    model = create_category_model
    model.cities << Category.create(:category_set => category_sets(:cities), :name => 'City')
    model.cities << 'Athens'
    assert_equal 2, model.cities.count
  end

  def test_two_different_categorizations_do_not_conflict
    categorize :cities
    categorize :countries
    create_set :countries
    model = create_category_model
    model.cities << 'Barcelona'
    model.countries << 'Japan'
    assert_equal 1, model.cities.count
    assert_equal 1, model.countries.count
    assert_equal 'Barcelona', model.cities.first.name
    assert_equal 'Japan', model.countries.first.name
  end

  protected

  def categorize attr, options = {}
    CategoryTestModel.class_eval do
      categorized_with attr, options
    end
  end

  def create_set key
    CategorySet.create(:key => key.to_s, :name => key.to_s)
  end
end

create_categories_test_model_backend