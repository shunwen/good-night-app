require "test_helper"

class Users::FollowingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    cookies[:user_id] = @user_one.id
  end

  test "should create follow" do
    assert_difference("Follow.count") do
      post users_followings_url, params: { followed_id: @user_two.id }
    end

    assert_redirected_to @user_two
    assert_equal "You are now following #{@user_two.name}.", flash[:notice]
  end

  test "should not create duplicate follow" do
    @user_one.follow(@user_two)

    assert_no_difference("Follow.count") do
      post users_followings_url, params: { followed_id: @user_two.id }
    end

    assert_redirected_to @user_two
    assert_equal "Unable to follow #{@user_two.name}.", flash[:alert]
  end

  test "should not follow self" do
    assert_no_difference("Follow.count") do
      post users_followings_url, params: { followed_id: @user_one.id }
    end

    assert_redirected_to @user_one
    assert_equal "Unable to follow #{@user_one.name}.", flash[:alert]
  end

  test "should destroy follow" do
    @user_one.follow(@user_two)

    assert_difference("Follow.count", -1) do
      delete users_followings_url, params: { followed_id: @user_two.id }
    end

    assert_redirected_to @user_two
    assert_equal "You unfollowed #{@user_two.name}.", flash[:notice]
  end

  test "should handle destroying non-existent follow" do
    assert_no_difference("Follow.count") do
      delete users_followings_url, params: { followed_id: @user_two.id }
    end

    assert_redirected_to @user_two
    assert_equal "Unable to unfollow #{@user_two.name}.", flash[:alert]
  end

  # JSON API tests
  test "should create follow as json" do
    assert_difference("Follow.count") do
      post users_followings_url, params: { followed_id: @user_two.id }, as: :json
    end

    assert_response :created
    assert_equal "application/json", response.media_type
  end

  test "should not create duplicate follow as json" do
    @user_one.follow(@user_two)

    assert_no_difference("Follow.count") do
      post users_followings_url, params: { followed_id: @user_two.id }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "application/json", response.media_type
  end

  test "should not follow self as json" do
    assert_no_difference("Follow.count") do
      post users_followings_url, params: { followed_id: @user_one.id }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "application/json", response.media_type
  end

  test "should destroy follow as json" do
    @user_one.follow(@user_two)

    assert_difference("Follow.count", -1) do
      delete users_followings_url, params: { followed_id: @user_two.id }, as: :json
    end

    assert_response :no_content
  end

  test "should handle destroying non-existent follow as json" do
    assert_no_difference("Follow.count") do
      delete users_followings_url, params: { followed_id: @user_two.id }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "application/json", response.media_type
  end
end
