# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/application.rb",  __FILE__)

require 'ubiquo/test/test_helper'

ActiveRecord::Migrator.migrate File.expand_path("../../install/db/migrate/", __FILE__)

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
  fixtures :ubiquo_users

  private

  def login(username = :josep)
    session[:ubiquo] ||= {}
    session[:ubiquo][:ubiquo_user_id] = ubiquo_users(username)
  end

end
