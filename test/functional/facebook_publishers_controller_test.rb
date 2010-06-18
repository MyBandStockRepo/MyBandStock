require 'test_helper'

class FacebookPublishersControllerTest < ActionController::TestCase
  setup do
    @facebook_publisher = facebook_publishers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:facebook_publishers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create facebook_publisher" do
    assert_difference('FacebookPublisher.count') do
      post :create, :facebook_publisher => @facebook_publisher.attributes
    end

    assert_redirected_to facebook_publisher_path(assigns(:facebook_publisher))
  end

  test "should show facebook_publisher" do
    get :show, :id => @facebook_publisher.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @facebook_publisher.to_param
    assert_response :success
  end

  test "should update facebook_publisher" do
    put :update, :id => @facebook_publisher.to_param, :facebook_publisher => @facebook_publisher.attributes
    assert_redirected_to facebook_publisher_path(assigns(:facebook_publisher))
  end

  test "should destroy facebook_publisher" do
    assert_difference('FacebookPublisher.count', -1) do
      delete :destroy, :id => @facebook_publisher.to_param
    end

    assert_redirected_to facebook_publishers_path
  end
end
