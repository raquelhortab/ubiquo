# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!
# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../install/db/migrate/", __FILE__)
ActionController::TestCase.route_testing_engine = :ubiquo_authentication

class ActiveSupport::TestCase
  fixtures :ubiquo_users
  include Ubiquo::Engine.routes.url_helpers
  include Rails.application.routes.mounted_helpers

  private

  def login(username = :josep)
    session[:ubiquo] ||= {}
    session[:ubiquo][:ubiquo_user_id] = ubiquo_users(username)
  end

end
