require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should create session with valid user_id" do
    post session_path, params: { user_id: @user.id }, as: :json

    assert_response :created
    # Check that user_id cookie was set (we can't easily test signed cookies in integration tests)
    assert cookies["user_id"]
  end

  test "should return unauthorized with invalid user_id" do
    post session_path, params: { user_id: 99999 }, as: :json

    assert_response :unauthorized
    assert_nil cookies["user_id"]
  end

  test "should return unauthorized with missing user_id" do
    post session_path, params: {}, as: :json

    assert_response :unauthorized
    assert_nil cookies["user_id"]
  end

  test "should destroy session" do
    # First sign in
    post session_path, params: { user_id: @user.id }, as: :json
    assert_response :created
    assert cookies["user_id"]

    # Then sign out
    delete session_path, as: :json
    assert_response :ok
    # Cookie should be empty string after deletion in test environment
    assert_equal "", cookies["user_id"]
  end

  test "should handle destroy session when not signed in" do
    delete session_path, as: :json
    assert_response :ok
    # Test passes as long as the response is OK
  end

  test "should authenticate user after session creation" do
    # Create session
    post session_path, params: { user_id: @user.id }, as: :json
    assert_response :created

    # Test that we can access /users/current (which requires authentication)
    get "/users/current", as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.id, json_response["id"]
    assert_equal @user.name, json_response["name"]
  end

  test "should not authenticate without valid session" do
    # Try to access protected endpoint without authentication
    get "/users/current", as: :json
    assert_response :unauthorized
  end
end
