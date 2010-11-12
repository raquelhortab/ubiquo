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
  @old_connector = UbiquoCategories::Connectors::Base.current_connector
end

def reload_old_categories_connector
  @old_connector.load!
end

def mock_categories_params params = nil
  Ubiquo::CategoriesController.any_instance.expects(:params).at_least(0).returns(params || {:category => {}})
end

def mock_categories_session session = nil
  Ubiquo::CategoriesController.any_instance.expects(:session).at_least(0).returns(session || {:category => {}})
end

def mock_categories_response
  Ubiquo::CategoriesController.any_instance.expects(:redirect_to).at_least(0)
  Ubiquo::CategoriesController.any_instance.stubs(:url_for).returns('')
end

# Prepares the proper mocks for a hook that will be using controller features
def mock_categories_controller
  mock_categories_params
  mock_categories_session
  mock_categories_response
  mock_categories_helper
end

# Prepares the proper mocks for a hook that will be using helper features
def mock_categories_helper
  # we stub well-known usable helper methods along with particular connector added methods
  stubs = {
    :params => {}, :t => '', :filter_info => '', :link_to => ''
  }.merge(UbiquoCategories::Connectors::Base.current_connector.mock_helper_stubs || {})

  stubs.each_pair do |method, retvalue|
    UbiquoCategories::Connectors::Base.current_connector::UbiquoCategoriesController::Helper.stubs(method).returns(retvalue)
    UbiquoCategories::Connectors::Base.current_connector::UbiquoHelpers::Helper.stubs(method).returns(retvalue)
  end
end

# Improvement for Mocha's Mock: stub_everything with a default return value other than nil.
class Mocha::Mock

  def stub_default_value= value
    @everything_stubbed_default_value = value
  end

  if !self.instance_methods.include?(:method_missing_with_stub_default_value.to_s)

    def method_missing_with_stub_default_value(symbol, *arguments, &block)
      value = method_missing_without_stub_default_value(symbol, *arguments, &block)
      if !@expectations.match_allowing_invocation(symbol, *arguments) && !@expectations.match(symbol, *arguments) && @everything_stubbed
        @everything_stubbed_default_value
      else
        value
      end
    end

    alias_method_chain :method_missing, :stub_default_value

  end

end

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end

def test_each_categories_connector
  Ubiquo::Config.context(:ubiquo_categories).get(:available_connectors).each do |conn|

    (class << self; self end).class_eval do
      eval <<-CONN
        def test_with_connector name, &block
        block_with_connector_load = Proc.new{
          "UbiquoCategories::Connectors::#{conn.to_s.classify}".constantize.load!
           block.bind(self).call
        }
        test_without_connector "#{conn}_\#{name}", &block_with_connector_load
      end
      CONN
      unless instance_methods.include? 'test_without_connector'
        alias_method :test_without_connector, :test
      end
      alias_method :test, :test_with_connector
    end
    yield
  end
end
