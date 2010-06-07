require 'test_helper'

class TwitterUsersControllerTest < ActionController::TestCase
  setup do
    @twitter_user = twitter_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_user" do
    assert_difference('TwitterUser.count') do
      post :create, :twitter_user => @twitter_user.attributes
    end

    assert_redirected_to twitter_user_path(assigns(:twitter_user))
  end

  test "should show twitter_user" do
    get :show, :id => @twitter_user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @twitter_user.to_param
    assert_response :success
  end

  test "should update twitter_user" do
    put :update, :id => @twitter_user.to_param, :twitter_user => @twitter_user.attributes
    assert_redirected_to twitter_user_path(assigns(:twitter_user))
  end

  test "should destroy twitter_user" do
    assert_difference('TwitterUser.count', -1) do
      delete :destroy, :id => @twitter_user.to_param
    end

    assert_redirected_to twitter_users_path
  end
end
