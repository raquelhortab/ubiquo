# -*- encoding: utf-8 -*-

require "rails/test_help"

module TestSupport

  # = Support for database manipulation
  #
  # This class creates the needed models and executes the pending migrations
  class Database
    class << self

      def migrate!
        migrations_dir = File.expand_path("../../../install/db/migrate/", __FILE__)

        ::ActiveRecord::Migrator.migrate migrations_dir
      end

      def create_test_model
        create_table :test_models do |t|
          t.string :name
        end

        # create models
        create_model('TestModel') do
        end
      end

      def connection
        ::ActiveRecord::Base.connection
      end

      protected

      def create_table(table_name, options = {}, &block)
        connection.drop_table table_name rescue nil

        unless connection.tables.include?(table_name)
          connection.create_table table_name, options, &block
        end
      end

      def create_model(class_name, &block)
        klass = Object.const_set(class_name, Class.new(::ActiveRecord::Base))

        klass.class_eval &block
      end
    end
  end
end
