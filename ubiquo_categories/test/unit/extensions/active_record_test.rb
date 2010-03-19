require File.dirname(__FILE__) + "/../../test_helper.rb"

class UbiquoCategories::ActiveRecordTest < ActiveSupport::TestCase
  def test_categorized_with
    assert_nothing_raised do
      CategoryTestModel.class_eval do
        categorized_with :city
      end
    end
  end

#  def test_categorized_with_defaults_to_size_1
#    CategoryTestModel.class_eval do
#      categorized_with :city
#    end
#    assert_raise MaximumCategoriesError do
#      model = create_category_model
#      model.city = 'SSS'
#    end
#  end
end

create_categories_test_model_backend