# -*- encoding: utf-8 -*-

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/application.rb",  __FILE__)
require File.expand_path("../test_support/database.rb",  __FILE__)
require 'ubiquo/test/test_helper'

TestSupport::Database.check_psql_adapter
# Run any available migration
TestSupport::Database.migrate!

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
  fixtures :all
end

class TestWidget < Widget
  self.allowed_options = :title, :description
end

class TestWidgetWithValidations < Widget
  self.allowed_options = :number
  self.validates :number, :numericality => true
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
  validates :title, :presence => true
end
