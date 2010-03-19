require File.dirname(__FILE__) + '/../test_helper'

class CategoryRelationTest < ActiveSupport::TestCase
  use_ubiquo_fixtures

  def test_should_create_category_relation
    assert_difference 'CategoryRelation.count' do
      category_relation = create_category_relation
      assert !category_relation.new_record?, "#{category_relation.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_category
    assert_no_difference "CategoryRelation.count" do
      category_relation = create_category_relation :category_id => nil
      assert category_relation.errors.on(:category)
    end
  end

  def test_should_require_related_object_id
    assert_no_difference "CategoryRelation.count" do
      category_relation = create_category_relation :related_object_id => nil
      assert category_relation.errors.on(:related_object)
    end
  end

  def test_should_require_related_object_type
    assert_no_difference "CategoryRelation.count" do
      category_relation = create_category_relation :related_object_type => nil
      assert category_relation.errors.on(:related_object)
    end
  end

  def test_should_require_valid_related_object_type
    assert_no_difference "CategoryRelation.count" do
      assert_raise NameError do
        create_category_relation :related_object_type => "HelloWorldClass"
      end
    end
  end

  private
  
  def create_category_relation(options = {})
    related = CategoryTestModel.create
    default_options = {
      :category_id => categories(:one).id, # integer
      :related_object_id => related.id, # integer
      :related_object_type => related.class.to_s, # string
    }
    CategoryRelation.create(default_options.merge(options))
  end
end

create_categories_test_model_backend
