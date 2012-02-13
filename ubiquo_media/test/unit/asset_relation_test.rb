require File.dirname(__FILE__) + "/../test_helper.rb"

class AssetRelationTest < ActiveSupport::TestCase

  def test_should_create_asset_relation
    assert_difference "AssetRelation.count" do
      asset_relation = create_asset_relation
      assert !asset_relation.new_record?, "#{asset_relation.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_asset
    assert_no_difference "AssetRelation.count" do
      asset_relation = create_asset_relation :asset_id => nil
      assert asset_relation.errors.include?(:asset)
    end
  end

  def test_should_require_related_object_id
    assert_no_difference "AssetRelation.count" do
      asset_relation = create_asset_relation :related_object_id => nil
      assert asset_relation.errors.include?(:related_object)
    end
  end

  def test_should_require_related_object_type
    assert_no_difference "AssetRelation.count" do
      asset_relation = create_asset_relation :related_object_type => nil
      assert asset_relation.errors.include?(:related_object)
    end
  end

  def test_should_require_valid_related_object_type
    assert_no_difference "AssetRelation.count" do
      assert_raise NameError do
        asset_relation = create_asset_relation :related_object_type => "HelloWorldClass"
      end
    end
  end

  def test_should_require_valid_related_object_values
    related_class = "TestModel"
    related_id = TestModel.maximum(:id) + 1
    assert_no_difference "AssetRelation.count" do
      asset_relation = create_asset_relation :related_object_id => related_id, :related_object_type => related_class
      assert asset_relation.errors.include?(:related_object)
    end
  end

  def test_should_return_default_values
    AssetRelation.expects(:uhook_default_values).returns('myvalue').with('owner', 'reflection')
    assert_equal 'myvalue', AssetRelation.default_values('owner', 'reflection')
  end

  private

  def create_asset_relation(options = {})
    AssetRelation.create({
      :asset_id            => assets(:video).id,
      :related_object_id   => test_models(:testing).id,
      :related_object_type => 'TestModel',
      :position            => 1
    }.merge(options))
  end
end
