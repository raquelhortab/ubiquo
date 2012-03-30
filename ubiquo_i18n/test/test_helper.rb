# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = false
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../install/db/migrate/", __FILE__)

def create_locale(options = {})
  default_options = {
    :iso_code => 'iso'
  }
  Locale.create(default_options.merge(options))
end

def create_model(options = {})
  TestModel.create(options)
end

def create_related_model(options = {})
  RelatedTestModel.create(options)
end

def create_translatable_related_model(options = {})
  TranslatableRelatedTestModel.create(options)
end

%w{TestModel RelatedTestModel UnsharedRelatedTestModel TranslatableRelatedTestModel ChainTestModelA ChainTestModelB ChainTestModelC OneOneTestModel CallbackTestModel}.each do |c|
  Object.const_set(c, Class.new(ActiveRecord::Base)) unless Object.const_defined? c
end

Object.const_set("InheritanceTestModel", Class.new(ActiveRecord::Base)) unless Object.const_defined? "InheritanceTestModel"

def create_test_model_backend
  return if @already_built

  conn = ActiveRecord::Base.connection
  options = {:translatable => true, :force => true}

  conn.create_table :test_models, options do |t|
    t.string :my_field
    t.string :my_other_field
    t.integer :test_model_id
    t.integer :related_test_model_id
  end

  conn.create_table :related_test_models, options.except(:translatable) do |t|
    t.integer :test_model_id
    t.integer :tracked_test_model_id
    t.string :my_field
  end

  conn.create_table :unshared_related_test_models, options.except(:translatable) do |t|
    t.integer :test_model_id
    t.string :my_field
  end

  conn.create_table :translatable_related_test_models, options do |t|
    t.integer :test_model_id
    t.integer :related_test_model_id
    t.integer :shared_related_test_model_id
    t.string :my_field
    t.string :common
    t.integer :lock_version, :default => 0
  end

  conn.create_table :chain_test_model_as, options do |t|
    t.integer :chain_test_model_b_id
    t.string :my_field
  end

  conn.create_table :chain_test_model_bs, options do |t|
    t.integer :chain_test_model_c_id
    t.string :my_field
  end

  conn.create_table :chain_test_model_cs, options do |t|
    t.integer :chain_test_model_a_id
    t.string :my_field
  end

  conn.create_table :one_one_test_models, options do |t|
    t.integer :one_one_test_model_id
    t.string :independent
    t.string :common
  end

  conn.create_table :inheritance_test_models, options do |t|
    t.integer :translatable_related_test_model_id
    t.integer :related_test_model_id
    t.integer :test_model_id
    t.string :my_field
    t.string :mixed
    t.string :type
  end

  conn.create_table :callback_test_models, options do |t|
    t.string :my_field
  end

  # Models used to test extensions
  TestModel.class_eval do
    belongs_to :related_test_model
    scope :my_field_is_1, {:conditions => {:my_field => '1'}}
    scope :my_field_is_2, {:conditions => {:my_field => '2'}}

    translatable :my_field
    filtered_search_scopes
    has_many :related_test_models
    has_many :unshared_related_test_models
    has_many :shared_related_test_models, :class_name => "RelatedTestModel"
    has_many :translatable_related_test_models

    has_many :inheritance_test_models, :dependent => :destroy
    has_many :through_related_test_models, :through => :inheritance_test_models, :source => :related_test_model
    has_many :test_models, :dependent => :destroy
    accepts_nested_attributes_for :test_models, :inheritance_test_models, :allow_destroy => true
    belongs_to :test_model

    share_translations_for :translatable_related_test_models, :test_models,
      :through_related_test_models, :inheritance_test_models, :test_model

    attr_accessor :abort_on_before_create
    attr_accessor :abort_on_before_update

    def before_create
      !self.abort_on_before_create
    end

    def before_update
      !self.abort_on_before_update
    end
  end

  RelatedTestModel.class_eval do
    belongs_to :test_model
    belongs_to :tracked_test_model, :translation_shared => true, :class_name => 'TestModel'

    has_many :inheritance_test_models, :translation_shared => true
    has_many :test_models, :translation_shared => false
    accepts_nested_attributes_for :test_models
  end

  UnsharedRelatedTestModel.class_eval do
    belongs_to :test_model
  end

  TranslatableRelatedTestModel.class_eval do
    translatable :my_field
    belongs_to :test_model
    belongs_to :related_test_model, :translation_shared => true
    has_many :inheritance_test_models, :translation_shared => true
    has_many :related_test_models
    belongs_to :shared_related_test_model, :translation_shared => true, :class_name => 'RelatedTestModel'
    accepts_nested_attributes_for :shared_related_test_model
  end

  ChainTestModelA.class_eval do
    translatable :my_field
    belongs_to :chain_test_model_b, :translation_shared => true
    has_many :chain_test_model_cs, :translation_shared => true
    has_many :chain_test_model_as, :translation_shared => true, :through => :chain_test_model_cs, :source => :chain_test_model_a
  end
  ChainTestModelB.class_eval do
    translatable :my_field
    belongs_to :chain_test_model_c, :translation_shared => true
    has_many :chain_test_model_as, :translation_shared => true
  end
  ChainTestModelC.class_eval do
    translatable :my_field, :shared_relations => :chain_test_model_bs
    belongs_to :chain_test_model_a, :translation_shared => true
    has_many :chain_test_model_bs, :translation_shared => true
  end

  OneOneTestModel.class_eval do
    translatable :independent
    belongs_to :one_one, :translation_shared => true, :foreign_key => 'one_one_test_model_id', :class_name => 'OneOneTestModel'
    has_one :one_one_test_model, :translation_shared => true
    accepts_nested_attributes_for :one_one_test_model
  end

  InheritanceTestModel.class_eval do
    translatable :my_field
    belongs_to :test_model
    belongs_to :related_test_model, :translation_shared => true
    belongs_to :translatable_related_test_model, :translation_shared => true
  end

  %w{FirstSubclass SecondSubclass}.each do |c|
    Object.const_set(c, Class.new(InheritanceTestModel)) unless Object.const_defined? c
  end

  SecondSubclass.class_eval do
    translatable :mixed
  end

  Object.const_set('GrandsonClass', Class.new(FirstSubclass)) unless Object.const_defined? 'GrandsonClass'
  @already_built = true
end

  class CallbackTestModel < ActiveRecord::Base
    translatable
    @@after_find_counter = 0
    @@after_initialize_counter = 0

    def self.reset_counter
      @@after_find_counter = 0
      @@after_initialize_counter = 0
    end

    def after_find
      @@after_find_counter = @@after_find_counter + 1
    end

    def after_initialize
      @@after_initialize_counter = @@after_initialize_counter + 1
    end

    def self.after_find_counter
      @@after_find_counter
    end

    def self.after_initialize_counter
      @@after_initialize_counter
    end

  end

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end
