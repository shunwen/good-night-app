require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should get index when authenticated" do
    cookies[:user_id] = @user.id
    get users_url
    assert_response :success
  end

  test "should redirect index when not authenticated" do
    get users_url
    assert_response :redirect
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { name: "Charlie" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user when authenticated" do
    cookies[:user_id] = @user.id
    get user_url(@other_user)
    assert_response :success
  end

  test "should redirect show when not authenticated" do
    get user_url(@user)
    assert_response :redirect
  end

  test "should get edit when authenticated" do
    cookies[:user_id] = @user.id
    get edit_user_url(@user)
    assert_response :success
  end

  test "should redirect edit when not authenticated" do
    get edit_user_url(@user)
    assert_response :redirect
  end

  test "should update user when authenticated" do
    cookies[:user_id] = @user.id
    patch user_url(@user), params: { user: { name: "Updated Name" } }
    assert_redirected_to user_url(@user)
  end

  test "should redirect update when not authenticated" do
    patch user_url(@user), params: { user: { name: "Updated Name" } }
    assert_response :redirect
  end

  test "should destroy user when authenticated" do
    cookies[:user_id] = @user.id
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  test "should redirect destroy when not authenticated" do
    assert_no_difference("User.count") do
      delete user_url(@user)
    end
    
    assert_response :redirect
  end
end
