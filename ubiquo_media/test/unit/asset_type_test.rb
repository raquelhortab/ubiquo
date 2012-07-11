require File.dirname(__FILE__) + "/../test_helper.rb"

class AssetTypeTest < ActiveSupport::TestCase

  def test_get_by_keys
    assert_equal AssetType.all, AssetType.get_by_keys(nil)
    assert_equal AssetType.all, AssetType.get_by_keys(:ALL)
    assert_equal [AssetType.find_by_key("image"),AssetType.find_by_key("doc")],
      AssetType.get_by_keys([:image,:doc])
    assert_equal [AssetType.find_by_key("doc")],
      AssetType.get_by_keys([:non_existent,:doc])
  end
end
