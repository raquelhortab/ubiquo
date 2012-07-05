# -*- encoding: utf-8 -*-

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.expand_path("../test_support/database.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

TestSupport::Database.check_psql_adapter
# Run any available migration
TestSupport::Database.migrate!
TestSupport::Database.check_psql_adapter

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures",  __FILE__)
ActionController::TestCase.route_testing_engine = :ubiquo_design

class ActiveSupport::TestCase
  fixtures :all
end

class TestWidget < Widget
  self.allowed_options = :title, :description
end

class TestWidgetWithValidations < Widget
  self.allowed_options = :number
  self.validates_numericality_of :number
end


# FIXME: Redefinition of classes due to ubiquo_media dependencies.
module ApplicationHelper
  # mock ubiquo_media helpers
  def media_selector(*)
    true
  end
end

Object.send(:remove_const, :StaticSection)
class StaticSection < Widget
  self.allowed_options = [:title, :summary, :body]
  validates_presence_of :title
end
