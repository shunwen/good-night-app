require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should get index when authenticated" do
    sign_in @user
    get users_url
    assert_response :success
  end

  test "unauthorized index when not authenticated" do
    get users_url
    assert_response :unauthorized
  end

  test "should create user" do
    sign_in @user

    assert_difference("User.count") do
      post users_url, params: { user: { name: "Charlie" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user when authenticated" do
    sign_in @user

    get user_url(@other_user)
    assert_response :success
  end

  test "unauthorized show when not authenticated" do
    get user_url(@user)
    assert_response :unauthorized
  end

  test "should destroy user when authenticated" do
    sign_in @user

    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  test "unauthorized destroy when not authenticated" do
    assert_no_difference("User.count") do
      delete user_url(@user)
    end

    assert_response :unauthorized
  end
end
