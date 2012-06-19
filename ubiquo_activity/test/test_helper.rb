# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.expand_path("../test_support/database.rb",  __FILE__)
require File.expand_path("../test_support/url_helper.rb",  __FILE__)
require File.expand_path("../test_support/access_control.rb",  __FILE__)
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

end


# FIXME, I copied authentication migration to dummy
ActiveRecord::Migrator.migrate File.expand_path("./test/dummy/db/migrate")

class Versionable < ActiveRecord::Base
  def publish
    self.is_published = true
  end
end

Versionable.connection.create_table :versionables do |t|
  t.string :title
  t.boolean :is_published, :default => false
  t.timestamps
end unless Versionable.table_exists?
