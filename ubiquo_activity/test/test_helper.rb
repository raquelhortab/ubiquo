# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/application.rb",  __FILE__)
require File.expand_path("../test_support/database.rb",  __FILE__)
require File.expand_path("../test_support/access_control.rb",  __FILE__)
require 'ubiquo/test/test_helper'

# Run any available migration
TestSupport::Database.migrate!
TestSupport::Database.create_test_model

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
  fixtures :all

  protected
end

class Versionable < ActiveRecord::Base
  has_paper_trail if self.respond_to?(:has_paper_trail)
  def publish
    self.is_published = true
  end
  attr_accessible :title
end

Versionable.connection.create_table :versionables do |t|
  t.string :title
  t.boolean :is_published, :default => false
  t.timestamps
end unless Versionable.table_exists?

