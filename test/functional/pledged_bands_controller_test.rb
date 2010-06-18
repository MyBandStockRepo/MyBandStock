require 'test_helper'

class PledgedBandsControllerTest < ActionController::TestCase
  setup do
    @pledged_band = pledged_bands(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pledged_bands)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pledged_band" do
    assert_difference('PledgedBand.count') do
      post :create, :pledged_band => @pledged_band.attributes
    end

    assert_redirected_to pledged_band_path(assigns(:pledged_band))
  end

  test "should show pledged_band" do
    get :show, :id => @pledged_band.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @pledged_band.to_param
    assert_response :success
  end

  test "should update pledged_band" do
    put :update, :id => @pledged_band.to_param, :pledged_band => @pledged_band.attributes
    assert_redirected_to pledged_band_path(assigns(:pledged_band))
  end

  test "should destroy pledged_band" do
    assert_difference('PledgedBand.count', -1) do
      delete :destroy, :id => @pledged_band.to_param
    end

    assert_redirected_to pledged_bands_path
  end
end
