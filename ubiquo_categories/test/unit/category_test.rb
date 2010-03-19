require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < ActiveSupport::TestCase

  def test_should_create_category
    assert_difference 'Category.count' do
      category = create_category
      assert !category.new_record?, "#{category.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Category.count' do
      category = create_category(:name => "")
      assert category.errors.on(:name)
    end
  end
  
  def test_should_filter_by_name
    Category.destroy_all
    category_1,category_2,category_3 = [
      create_category(:name => "try to find me"),
      create_category(:name => "try to FinD me"),
      create_category(:name => "I don't appear"),
    ]
    
    assert_equal_set [category_1,category_2], Category.filtered_search({:text => "find"})
  end
  
  private
  
  def create_category(options = {})
    default_options = {
      :name => 'MyString', # string
      :description => 'MyText', # text
    }
    Category.create(default_options.merge(options))
  end
end
