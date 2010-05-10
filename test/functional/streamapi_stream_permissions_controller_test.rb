require 'test_helper'

class StreamapiStreamPermissionsControllerTest < ActionController::TestCase
  setup do
    @streamapi_stream_permission = streamapi_stream_permissions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:streamapi_stream_permissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create streamapi_stream_permission" do
    assert_difference('StreamapiStreamPermission.count') do
      post :create, :streamapi_stream_permission => @streamapi_stream_permission.attributes
    end

    assert_redirected_to streamapi_stream_permission_path(assigns(:streamapi_stream_permission))
  end

  test "should show streamapi_stream_permission" do
    get :show, :id => @streamapi_stream_permission.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @streamapi_stream_permission.to_param
    assert_response :success
  end

  test "should update streamapi_stream_permission" do
    put :update, :id => @streamapi_stream_permission.to_param, :streamapi_stream_permission => @streamapi_stream_permission.attributes
    assert_redirected_to streamapi_stream_permission_path(assigns(:streamapi_stream_permission))
  end

  test "should destroy streamapi_stream_permission" do
    assert_difference('StreamapiStreamPermission.count', -1) do
      delete :destroy, :id => @streamapi_stream_permission.to_param
    end

    assert_redirected_to streamapi_stream_permissions_path
  end
end
