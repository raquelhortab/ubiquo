# This file includes common ubiquo gem configuration for testing

require "rails/test_help"
require "rails/generators"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

ActionController::TestCase.route_testing_engine = :ubiquo_core

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end

# FIXME this should be done in another way
def mocked_superadmin_ubiquo_user(value = true)
  mocked_admin_ubiquo_user.tap do |user|
    user.stubs(:is_superadmin?).returns(value)
  end
end

def mocked_admin_ubiquo_user(value = true)
  mocked_ubiquo_user.tap do |user|
    user.stubs(:is_admin?).returns(value)
  end
end

def mocked_ubiquo_user
  mock('user').tap do |user|
    user.stubs(:last_locale).returns(:es)
  end
end
