require 'test_helper'

class LiveStreamSeriesControllerTest < ActionController::TestCase
  setup do
    @live_stream_series = live_stream_series(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:live_stream_series)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create live_stream_series" do
    assert_difference('LiveStreamSeries.count') do
      post :create, :live_stream_series => @live_stream_series.attributes
    end

    assert_redirected_to live_stream_series_path(assigns(:live_stream_series))
  end

  test "should show live_stream_series" do
    get :show, :id => @live_stream_series.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @live_stream_series.to_param
    assert_response :success
  end

  test "should update live_stream_series" do
    put :update, :id => @live_stream_series.to_param, :live_stream_series => @live_stream_series.attributes
    assert_redirected_to live_stream_series_path(assigns(:live_stream_series))
  end

  test "should destroy live_stream_series" do
    assert_difference('LiveStreamSeries.count', -1) do
      delete :destroy, :id => @live_stream_series.to_param
    end

    assert_redirected_to live_stream_series_path
  end
end
