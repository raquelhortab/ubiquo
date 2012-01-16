# -*- encoding: utf-8 -*-

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rails/generators"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

class ::Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  setup :add_routes_file
  teardown :destroy_destination

  protected

  def add_routes_file
    routes = <<-reof
      Dummy::Application.routes.draw do
      end
    reof
    mkdir_p("#{destination_root}/config")
    File.open("#{destination_root}/config/routes.rb", 'w') { |f| f.write routes }
  end

  def destroy_destination
    rm_rf(destination_root)
  end
end
