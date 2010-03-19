require File.dirname(__FILE__) + '/../../test_helper'

class Ubiquo::CategoriesControllerTest < ActionController::TestCase
  def setup
    session[:locale] = "en_US"
  end
  
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_get_show
    get :show, :id => categories(:one).id
    assert_response :success
  end

  def test_should_create_category
    assert_difference('Category.count') do
      post :create, :category => category_attributes
    end

    assert_redirected_to ubiquo_categories_url
  end

  def test_should_get_edit
    get :edit, :id => categories(:one).id
    assert_response :success
  end

  def test_should_update_category
    put :update, :id => categories(:one).id, :category => category_attributes
    assert_redirected_to ubiquo_categories_url
  end

  def test_should_destroy_category
    assert_difference('Category.count', -1) do
      delete :destroy, :id => categories(:one).id
    end
    assert_redirected_to ubiquo_categories_url
  end
  
  private

  def category_attributes(options = {})
    default_options = {
              :name => 'MyString', # string
              :description => 'MyText', # text
          }
    default_options.merge(options)  
  end

  def create_category(options = {})
    Category.create(category_attributes(options))
  end
      
end
