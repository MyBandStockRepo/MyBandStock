require 'test_helper'

class StreamapiStreamThemesControllerTest < ActionController::TestCase
  setup do
    @streamapi_stream_theme = streamapi_stream_themes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:streamapi_stream_themes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create streamapi_stream_theme" do
    assert_difference('StreamapiStreamTheme.count') do
      post :create, :streamapi_stream_theme => @streamapi_stream_theme.attributes
    end

    assert_redirected_to streamapi_stream_theme_path(assigns(:streamapi_stream_theme))
  end

  test "should show streamapi_stream_theme" do
    get :show, :id => @streamapi_stream_theme.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @streamapi_stream_theme.to_param
    assert_response :success
  end

  test "should update streamapi_stream_theme" do
    put :update, :id => @streamapi_stream_theme.to_param, :streamapi_stream_theme => @streamapi_stream_theme.attributes
    assert_redirected_to streamapi_stream_theme_path(assigns(:streamapi_stream_theme))
  end

  test "should destroy streamapi_stream_theme" do
    assert_difference('StreamapiStreamTheme.count', -1) do
      delete :destroy, :id => @streamapi_stream_theme.to_param
    end

    assert_redirected_to streamapi_stream_themes_path
  end
end
