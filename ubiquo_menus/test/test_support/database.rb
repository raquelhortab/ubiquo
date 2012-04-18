# -*- encoding: utf-8 -*-

require "rails/test_help"

module TestSupport

  # = Support for database manipulation
  #
  # This class executes the pending migrations
  class Database
    class << self

      def migrate!
        migrations_dir = File.expand_path("../../../install/db/migrate/", __FILE__)

        ::ActiveRecord::Migrator.migrate migrations_dir
      end

      def check_psql_adapter
        if connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
          connection.client_min_messages = "ERROR"
        end
      end

      def connection
        ::ActiveRecord::Base.connection
      end
    end
  end
end
