require 'test_helper'

class StreamapiStreamsControllerTest < ActionController::TestCase
  setup do
    @streamapi_stream = streamapi_streams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:streamapi_streams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create streamapi_stream" do
    assert_difference('StreamapiStream.count') do
      post :create, :streamapi_stream => @streamapi_stream.attributes
    end

    assert_redirected_to streamapi_stream_path(assigns(:streamapi_stream))
  end

  test "should show streamapi_stream" do
    get :show, :id => @streamapi_stream.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @streamapi_stream.to_param
    assert_response :success
  end

  test "should update streamapi_stream" do
    put :update, :id => @streamapi_stream.to_param, :streamapi_stream => @streamapi_stream.attributes
    assert_redirected_to streamapi_stream_path(assigns(:streamapi_stream))
  end

  test "should destroy streamapi_stream" do
    assert_difference('StreamapiStream.count', -1) do
      delete :destroy, :id => @streamapi_stream.to_param
    end

    assert_redirected_to streamapi_streams_path
  end
end
