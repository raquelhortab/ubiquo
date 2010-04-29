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

  CategoryTranslatableTestModel.class_eval do
    translatable :field
  end
end

def categorize attr, options = {}
  CategoryTestModel.class_eval do
    categorized_with attr, options
  end
end

def create_category_set(options = {})
  default_options = {
    :name => 'MyString', # string
    :key => 'MyString', # string
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

def save_current_connector
  @old_connector = UbiquoCategories::Connectors::Base.current_connector
end

def reload_old_connector
  @old_connector.load!
end

def mock_params params = nil
  Ubiquo::CategoriesController.any_instance.expects(:params).at_least(0).returns(params || {:category => {}})
end

def mock_session session = nil
  Ubiquo::CategoriesController.any_instance.expects(:session).at_least(0).returns(session || {:category => {}})
end

def mock_response
  Ubiquo::CategoriesController.any_instance.expects(:redirect_to).at_least(0)
end

# Prepares the proper mocks for a hook that will be using controller features
def mock_controller
  mock_params
  mock_session
  mock_response
end

# Prepares the proper mocks for a hook that will be using helper features
def mock_helper
  # we stub well-known usable helper methods along with particular connector added methods
  stubs = {
    :params => {}, :t => '', :filter_info => '',
    :render_filter => '', :link_to => ''
  }.merge(UbiquoCategories::Connectors::Base.instance_variable_get('@methods_with_returns') || {})

  stubs.each_pair do |method, retvalue|
    UbiquoCategories::Connectors::Base.current_connector::UbiquoCategoriesController::Helper.stubs(method).returns(retvalue)
  end
end

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end

