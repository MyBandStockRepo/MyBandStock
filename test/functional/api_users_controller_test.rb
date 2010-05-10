require 'test_helper'

class ApiUsersControllerTest < ActionController::TestCase
  setup do
    @api_user = api_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:api_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create api_user" do
    assert_difference('ApiUser.count') do
      post :create, :api_user => @api_user.attributes
    end

    assert_redirected_to api_user_path(assigns(:api_user))
  end

  test "should show api_user" do
    get :show, :id => @api_user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @api_user.to_param
    assert_response :success
  end

  test "should update api_user" do
    put :update, :id => @api_user.to_param, :api_user => @api_user.attributes
    assert_redirected_to api_user_path(assigns(:api_user))
  end

  test "should destroy api_user" do
    assert_difference('ApiUser.count', -1) do
      delete :destroy, :id => @api_user.to_param
    end

    assert_redirected_to api_users_path
  end
end
