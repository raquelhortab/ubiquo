# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.expand_path("../test_support/database.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method            = :test
ActionMailer::Base.perform_deliveries         = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

TestSupport::Database.check_psql_adapter
# Run any available migration
TestSupport::Database.migrate!
TestSupport::Database.create_test_model

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures",  __FILE__)

class ActiveSupport::TestCase
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
end

