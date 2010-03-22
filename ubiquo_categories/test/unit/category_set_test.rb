require File.dirname(__FILE__) + '/../test_helper'

class CategorySetTest < ActiveSupport::TestCase
  use_ubiquo_fixtures

  def test_should_create_category_set
    assert_difference 'CategorySet.count' do
      category_set = create_category_set
      assert !category_set.new_record?, "#{category_set.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'CategorySet.count' do
      category_set = create_category_set(:name => "")
      assert category_set.errors.on(:name)
    end
  end

  def test_should_have_categories
    category_set = create_category_set
    assert_equal [], category_set.categories
  end

  def test_should_allow_add_string_categories
    category_set = create_category_set
    category_set.categories << 'category'
    assert_equal 1, category_set.categories.size
    assert_equal 'category', category_set.categories.first.name
    assert_raise ActiveRecord::AssociationTypeMismatch do
      category_set.categories << 1
    end
  end
  
  def test_should_filter_by_name
    CategorySet.destroy_all
    category_set_1,category_set_2,category_set_3 = [
      create_category_set(:name => "try to find me"),
      create_category_set(:name => "try to FinD me"),
      create_category_set(:name => "I don't appear"),
    ]
    
    assert_equal_set [category_set_1,category_set_2], CategorySet.filtered_search({:text => "find"})
  end
  
  private
  
  def create_category_set(options = {})
    default_options = {
      :name => 'MyString', # string
      :key => 'MyString', # string
    }
    CategorySet.create(default_options.merge(options))
  end
end
