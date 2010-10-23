require 'test_helper'

class TwitterCrawlerHashTagsControllerTest < ActionController::TestCase
  setup do
    @twitter_crawler_hash_tag = twitter_crawler_hash_tags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_crawler_hash_tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_crawler_hash_tag" do
    assert_difference('TwitterCrawlerHashTag.count') do
      post :create, :twitter_crawler_hash_tag => @twitter_crawler_hash_tag.attributes
    end

    assert_redirected_to twitter_crawler_hash_tag_path(assigns(:twitter_crawler_hash_tag))
  end

  test "should show twitter_crawler_hash_tag" do
    get :show, :id => @twitter_crawler_hash_tag.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @twitter_crawler_hash_tag.to_param
    assert_response :success
  end

  test "should update twitter_crawler_hash_tag" do
    put :update, :id => @twitter_crawler_hash_tag.to_param, :twitter_crawler_hash_tag => @twitter_crawler_hash_tag.attributes
    assert_redirected_to twitter_crawler_hash_tag_path(assigns(:twitter_crawler_hash_tag))
  end

  test "should destroy twitter_crawler_hash_tag" do
    assert_difference('TwitterCrawlerHashTag.count', -1) do
      delete :destroy, :id => @twitter_crawler_hash_tag.to_param
    end

    assert_redirected_to twitter_crawler_hash_tags_path
  end
end
