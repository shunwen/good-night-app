require "test_helper"

class Users::SleepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sleep = sleeps(:one)
    cookies[:user_id] = @sleep.user_id
  end

  test "should get index" do
    get users_sleeps_url
    assert_response :success
  end

  test "should get new" do
    get new_users_sleep_url
    assert_response :success
  end

  test "should create sleep" do
    assert_difference("Sleep.count") do
      post users_sleeps_url, params: { sleep: { started_at_raw: @sleep.started_at_raw, stopped_at_raw: @sleep.stopped_at_raw } }
    end

    assert_redirected_to users_sleep_url(Sleep.last)
  end

  test "should show sleep" do
    get users_sleep_url(@sleep)
    assert_response :success
  end

  test "should get edit" do
    get edit_users_sleep_url(@sleep)
    assert_response :success
  end

  test "should update sleep" do
    patch users_sleep_url(@sleep), params: { sleep: { started_at_raw: @sleep.started_at_raw, stopped_at_raw: @sleep.stopped_at_raw } }
    assert_redirected_to users_sleep_url(@sleep)
  end

  test "should destroy sleep" do
    assert_difference("Sleep.count", -1) do
      delete users_sleep_url(@sleep)
    end

    assert_redirected_to users_sleeps_url
  end

  # JSON API tests
  test "should get index as json" do
    get users_sleeps_url, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "should show sleep as json" do
    get users_sleep_url(@sleep), as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "should create sleep as json" do
    assert_difference("Sleep.count") do
      post users_sleeps_url, params: { sleep: { started_at_raw: "2025-01-01 22:00:00", stopped_at_raw: "2025-01-02 06:00:00" } }, as: :json
    end

    assert_response :created
    assert_equal "application/json", response.media_type
  end

  test "should update sleep as json" do
    patch users_sleep_url(@sleep), params: { sleep: { started_at_raw: "2025-01-01 21:00:00" } }, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "should destroy sleep as json" do
    assert_difference("Sleep.count", -1) do
      delete users_sleep_url(@sleep), as: :json
    end

    assert_response :no_content
  end

  test "should return unprocessable entity for invalid sleep as json" do
    post users_sleeps_url, params: { sleep: { started_at_raw: nil } }, as: :json
    assert_response :unprocessable_entity
    assert_equal "application/json", response.media_type
  end
end
