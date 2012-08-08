# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/application.rb",  __FILE__)
require 'ubiquo/test/test_helper'

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../install/db/migrate/", __FILE__)
