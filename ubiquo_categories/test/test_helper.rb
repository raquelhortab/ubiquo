require File.dirname(__FILE__) + "/../../../../test/test_helper.rb"

def create_categories_test_model_backend
  # Creates a test table for AR things work properly
  %w{category_test_models category_translatable_test_models}.each do |table|
    if ActiveRecord::Base.connection.tables.include?(table)
      ActiveRecord::Base.connection.drop_table table
    end
  end
  ActiveRecord::Base.connection.create_table :category_translatable_test_models, :translatable => true do |t|
    t.string :field
  end

  ActiveRecord::Base.connection.create_table :category_test_models do |t|
    t.string :field
  end
  
  %w{CategoryTestModel CategoryTranslatableTestModel}.each do |klass|
    Object.const_set(klass, Class.new(ActiveRecord::Base)) unless Object.const_defined? klass
  end
end

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end
