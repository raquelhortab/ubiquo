# -*- encoding: utf-8 -*-

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.expand_path("../test_support/database.rb",  __FILE__)
require File.expand_path("../test_support/url_helper.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

TestSupport::Database.check_psql_adapter
# Run any available migration
TestSupport::Database.migrate!
TestSupport::Database.check_psql_adapter

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures",  __FILE__)

UbiquoDesign::Structure.define{}


class ActiveSupport::TestCase
  fixtures :all

  protected

  def menu_attributes
    {
      :name => 'menu'
    }
  end

  def page_attributes
    {
      :id               => 10000,
      :name             => "Start page",
      :url_name         => "",
      :page_template    => "static",
      :published_id     => nil,
      :key              => "one",
      :is_static        => true,
      :is_modified      => false,
      :meta_title       => "Static example page",
      :meta_description => "Meta description text",
      :meta_keywords    => "static,test,start",
    }
  end

  def block_attributes
    {
      :block_type        => 'main',
      :page_id           => first_or_create(:page).id
    }
  end

  def create(model, attributes = {})
    custom_method = "create_#{model}"
    return send(custom_method, attributes) if self.respond_to?(custom_method)
    klass = cast_model(model)
    default_attributes = send("#{model}_attributes")
    klass.create(attributes.reverse_merge(default_attributes))
  end

  def first_or_create(model)
    klass = cast_model(model)
    klass.first || create(model)
  end

  def cast_model(model)
    model = model.to_s.classify.constantize if model.kind_of?(Symbol)
    model
  end
end

# FIXME, I copied design migration to dummy
ActiveRecord::Migrator.migrate File.expand_path("./test/dummy/db/migrate")

