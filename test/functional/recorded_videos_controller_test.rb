require 'test_helper'

class RecordedVideosControllerTest < ActionController::TestCase
  setup do
    @recorded_video = recorded_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recorded_videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recorded_video" do
    assert_difference('RecordedVideo.count') do
      post :create, :recorded_video => @recorded_video.attributes
    end

    assert_redirected_to recorded_video_path(assigns(:recorded_video))
  end

  test "should show recorded_video" do
    get :show, :id => @recorded_video.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @recorded_video.to_param
    assert_response :success
  end

  test "should update recorded_video" do
    put :update, :id => @recorded_video.to_param, :recorded_video => @recorded_video.attributes
    assert_redirected_to recorded_video_path(assigns(:recorded_video))
  end

  test "should destroy recorded_video" do
    assert_difference('RecordedVideo.count', -1) do
      delete :destroy, :id => @recorded_video.to_param
    end

    assert_redirected_to recorded_videos_path
  end
end
