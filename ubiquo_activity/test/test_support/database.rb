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
          media_attachment :images, :size => :many
          media_attachment :sized, :size => 2, :required => false
        end
      end

      def i18n_setup
        # create tables
        create_table :test_media_translatables, :translatable => true do |t|
          t.string :field1
          t.string :field2
        end

        create_table :test_media_translatable_models, :translatable => true do |t|
          t.string :field1
          t.string :field2
          t.integer :test_media_translatable_id
        end

        # create models
        create_model('TestMediaTranslatable') do
          translatable
          has_many :test_media_translatable_models
          accepts_nested_attributes_for :test_media_translatable_models
          share_translations_for :test_media_translatable_models
          validates_length_of :test_media_translatable_models, :minimum => 1
        end

        create_model('TestMediaTranslatableModel') do
          translatable
          belongs_to :test_media_translatable_model_with_relation
          media_attachment :sized,        :size => 2, :required => false
          media_attachment :sized_shared, :size => 2, :required => true, :translation_shared => true
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
