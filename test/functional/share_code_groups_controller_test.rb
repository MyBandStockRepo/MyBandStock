require 'test_helper'

class ShareCodeGroupsControllerTest < ActionController::TestCase
  setup do
    @share_code_group = share_code_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:share_code_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create share_code_group" do
    assert_difference('ShareCodeGroup.count') do
      post :create, :share_code_group => @share_code_group.attributes
    end

    assert_redirected_to share_code_group_path(assigns(:share_code_group))
  end

  test "should show share_code_group" do
    get :show, :id => @share_code_group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @share_code_group.to_param
    assert_response :success
  end

  test "should update share_code_group" do
    put :update, :id => @share_code_group.to_param, :share_code_group => @share_code_group.attributes
    assert_redirected_to share_code_group_path(assigns(:share_code_group))
  end

  test "should destroy share_code_group" do
    assert_difference('ShareCodeGroup.count', -1) do
      delete :destroy, :id => @share_code_group.to_param
    end

    assert_redirected_to share_code_groups_path
  end
end
