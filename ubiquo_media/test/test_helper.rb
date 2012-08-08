# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/application.rb",  __FILE__)
require 'ubiquo/test/test_helper'
require File.expand_path("../test_support/database.rb",  __FILE__)

TestSupport::Database.check_psql_adapter
# Run any available migration
TestSupport::Database.migrate!
TestSupport::Database.create_test_model

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
  fixtures :all

  protected

  # Create a test file for tests
  def _test_file(contents = "contents", ext = "txt")
    Tempfile.new("test." + ext).tap do |file|
      file.write contents
      file.flush
    end
  end

  def sample_image
    File.open(File.join(File.dirname(__FILE__),
              "/fixtures/resources/sample.png"))
  end

  def mock_asset_params(params = {})
    mock_params(params, Ubiquo::AssetsController)
  end

  def mock_assets_controller
    mock_controller(Ubiquo::AssetsController)
  end

  def mock_media_helper
    mock_helper(:ubiquo_media)
  end
end

class AssetType # Using this model because is very simple and has no validations
  media_attachment :simple
  media_attachment :multiple,   :size =>  :many
  media_attachment :sized,      :size =>  2
  media_attachment :all_types,  :types => :ALL
  media_attachment :some_types, :types => %w{audio video}
  attr_accessible :simple_attributes, :multiple_attributes, :sized_attributes,
    :all_types_attributes, :some_types_attributes, :my_attachment_attributes,
    :simple_ids, :sized, :multiple, :multiple_asset_relations_attributes, :some_type_ids
end

