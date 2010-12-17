require File.dirname(__FILE__) + "/../../../../test/test_helper.rb"
require 'mocha'

def create_categories_test_model_backend
  # Creates a test table for AR things work properly
  %w{category_test_models category_translatable_test_models category_test_model_bases empty_test_model_bases}.each do |table|
    if ActiveRecord::Base.connection.tables.include?(table)
      ActiveRecord::Base.connection.drop_table table
    end
  end
  ActiveRecord::Base.connection.create_table :category_translatable_test_models, :translatable => true do |t|
    t.string :field
  end

  ActiveRecord::Base.connection.create_table :category_test_model_bases, :translatable => true do |t|
    t.string :field
  end

  ActiveRecord::Base.connection.create_table :empty_test_model_bases, :translatable => true do |t|
    t.string :field
  end

  ActiveRecord::Base.connection.create_table :category_test_models do |t|
    t.string :field
  end

  %w{CategoryTestModel CategoryTranslatableTestModel}.each do |klass|
    Object.const_set(klass, Class.new(ActiveRecord::Base)) unless Object.const_defined? klass
  end
  Object.const_set("CategoryTestModelBase", Class.new(ActiveRecord::Base)) unless Object.const_defined? "CategoryTestModelBase"
  Object.const_set("CategoryTestModelSubOne", Class.new(CategoryTestModelBase)) unless Object.const_defined? "CategoryTestModelSubOne"
  Object.const_set("CategoryTestModelSubTwo", Class.new(CategoryTestModelSubOne)) unless Object.const_defined? "CategoryTestModelSubTwo"

  Object.const_set("EmptyTestModelBase", Class.new(ActiveRecord::Base)) unless Object.const_defined? "EmptyTestModelBase"
  Object.const_set("EmptyTestModelSubOne", Class.new(EmptyTestModelBase)) unless Object.const_defined? "EmptyTestModelSubOne"
  Object.const_set("EmptyTestModelSubTwo", Class.new(EmptyTestModelSubOne)) unless Object.const_defined? "EmptyTestModelSubTwo"
end

def categorize attr, options = {}
  CategoryTestModel.class_eval do
    categorized_with attr, options
  end
end

def categorize_base attr, options = {}
  CategoryTestModelBase.class_eval do
    categorized_with attr, options
  end
end

def create_category_set(options = {})
  default_options = {
    :name => 'MyString', # string
    :key => rand.to_s, # string
    :is_editable => true
  }
  CategorySet.create(default_options.merge(options))
end

def create_set key
  CategorySet.create(:key => key.to_s, :name => key.to_s)
end

def create_category_model
  CategoryTestModel.create
end

def create_i18n_category_model
  CategoryTranslatableTestModel.create(:locale => 'en')
end

def save_current_categories_connector
  save_current_connector(:ubiquo_categories)
end

def reload_old_categories_connector
  reload_old_connector(:ubiquo_categories)
end

def mock_categories_params params = {}
  mock_params(params, Ubiquo::CategoriesController)
end

def mock_categories_controller
  mock_controller(Ubiquo::CategoriesController)
end

def mock_categories_helper
  mock_helper(:ubiquo_categories)
end

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end
