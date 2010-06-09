require 'test_helper'

class ShareCodesControllerTest < ActionController::TestCase
  setup do
    @share_code = share_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:share_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create share_code" do
    assert_difference('ShareCode.count') do
      post :create, :share_code => @share_code.attributes
    end

    assert_redirected_to share_code_path(assigns(:share_code))
  end

  test "should show share_code" do
    get :show, :id => @share_code.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @share_code.to_param
    assert_response :success
  end

  test "should update share_code" do
    put :update, :id => @share_code.to_param, :share_code => @share_code.attributes
    assert_redirected_to share_code_path(assigns(:share_code))
  end

  test "should destroy share_code" do
    assert_difference('ShareCode.count', -1) do
      delete :destroy, :id => @share_code.to_param
    end

    assert_redirected_to share_codes_path
  end
end
