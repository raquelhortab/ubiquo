require File.dirname(__FILE__) + '/../../test_helper'

class Ubiquo::<%= controller_class_name %>ControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_<%= file_name %>
    assert_difference('<%= class_name %>.count') do
      post :create, :<%= file_name %> => <%= file_name %>_attributes
    end

    assert_redirected_to ubiquo_<%= table_name %>_path
  end

  def test_should_get_edit
    get :edit, :id => <%= table_name %>(:one).id
    assert_response :success
  end

  def test_should_update_<%= file_name %>
    put :update, :id => <%= table_name %>(:one).id, :<%= file_name %> => <%= file_name %>_attributes
    assert_redirected_to ubiquo_<%= table_name %>_path
  end

  def test_should_destroy_<%= file_name %>
    assert_difference('<%= class_name %>.count', -1) do
      delete :destroy, :id => <%= table_name %>(:one).id
    end
    assert_redirected_to ubiquo_<%= table_name %>_path
  end
  
  private

  def <%= file_name %>_attributes(options = {})
    default_options = {
      <% for attribute in attributes -%>
        :<%= attribute.name %> => '<%= attribute.default %>', # <%= attribute.type.to_s %>
      <% end -%>
    }
    default_options.merge(options)  
  end

  def create_<%= file_name %>(options = {})
    <%= name.classify %>.create(<%= name %>_attributes(options))
  end
      
end
