require 'test_helper'

class PromotionalCodesControllerTest < ActionController::TestCase
  setup do
    @promotional_code = promotional_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:promotional_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create promotional_code" do
    assert_difference('PromotionalCode.count') do
      post :create, :promotional_code => @promotional_code.attributes
    end

    assert_redirected_to promotional_code_path(assigns(:promotional_code))
  end

  test "should show promotional_code" do
    get :show, :id => @promotional_code.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @promotional_code.to_param
    assert_response :success
  end

  test "should update promotional_code" do
    put :update, :id => @promotional_code.to_param, :promotional_code => @promotional_code.attributes
    assert_redirected_to promotional_code_path(assigns(:promotional_code))
  end

  test "should destroy promotional_code" do
    assert_difference('PromotionalCode.count', -1) do
      delete :destroy, :id => @promotional_code.to_param
    end

    assert_redirected_to promotional_codes_path
  end
end
