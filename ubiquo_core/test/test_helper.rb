# -*- encoding: utf-8 -*-

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'ubiquo/test/dummy_app'
require 'ubiquo/test/test_helper'

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../install/db/migrate/", __FILE__)

require File.dirname(__FILE__) + '/relation_helper'
require 'rake' # For cron job testing


class ActiveSupport::TestCase
  def enable_settings_override
    Ubiquo::Settings[:ubiquo][:settings_overridable] = true
  end

  def disable_settings_override
    Ubiquo::Settings[:ubiquo][:settings_overridable] = false
  end
end

class ::Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  teardown :destroy_destination

  protected

  def destroy_destination
    rm_rf(destination_root)
  end

end