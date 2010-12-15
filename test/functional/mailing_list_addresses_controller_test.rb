require 'test_helper'

class MailingListAddressesControllerTest < ActionController::TestCase
  setup do
    @mailing_list_address = mailing_list_addresses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mailing_list_addresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mailing_list_address" do
    assert_difference('MailingListAddress.count') do
      post :create, :mailing_list_address => @mailing_list_address.attributes
    end

    assert_redirected_to mailing_list_address_path(assigns(:mailing_list_address))
  end

  test "should show mailing_list_address" do
    get :show, :id => @mailing_list_address.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @mailing_list_address.to_param
    assert_response :success
  end

  test "should update mailing_list_address" do
    put :update, :id => @mailing_list_address.to_param, :mailing_list_address => @mailing_list_address.attributes
    assert_redirected_to mailing_list_address_path(assigns(:mailing_list_address))
  end

  test "should destroy mailing_list_address" do
    assert_difference('MailingListAddress.count', -1) do
      delete :destroy, :id => @mailing_list_address.to_param
    end

    assert_redirected_to mailing_list_addresses_path
  end
end
