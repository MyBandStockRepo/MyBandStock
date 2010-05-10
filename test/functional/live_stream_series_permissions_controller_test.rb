require 'test_helper'

class LiveStreamSeriesPermissionsControllerTest < ActionController::TestCase
  setup do
    @live_stream_series_permission = live_stream_series_permissions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:live_stream_series_permissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create live_stream_series_permission" do
    assert_difference('LiveStreamSeriesPermission.count') do
      post :create, :live_stream_series_permission => @live_stream_series_permission.attributes
    end

    assert_redirected_to live_stream_series_permission_path(assigns(:live_stream_series_permission))
  end

  test "should show live_stream_series_permission" do
    get :show, :id => @live_stream_series_permission.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @live_stream_series_permission.to_param
    assert_response :success
  end

  test "should update live_stream_series_permission" do
    put :update, :id => @live_stream_series_permission.to_param, :live_stream_series_permission => @live_stream_series_permission.attributes
    assert_redirected_to live_stream_series_permission_path(assigns(:live_stream_series_permission))
  end

  test "should destroy live_stream_series_permission" do
    assert_difference('LiveStreamSeriesPermission.count', -1) do
      delete :destroy, :id => @live_stream_series_permission.to_param
    end

    assert_redirected_to live_stream_series_permissions_path
  end
end
