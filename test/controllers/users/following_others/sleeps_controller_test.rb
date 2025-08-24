require "test_helper"

class Users::FollowingOthers::SleepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @sleep_one = sleeps(:one)
    @sleep_two = sleeps(:two)
    cookies[:user_id] = @user_one.id
  end

  test "should get index when user has followings with sleeps" do
    @user_one.following_others << @user_two
    get users_following_others_sleeps_url
    assert_response :success
  end

  test "should show only sleep records from followed users" do
    @user_one.following_others << @user_two
    
    get users_following_others_sleeps_url
    assert_response :success
    
    # Should include sleep from followed user (user_two)
    assert_select "div#sleep_#{@sleep_two.id}", count: 1
    
    # Should not include own sleep record (user_one)
    assert_select "div#sleep_#{@sleep_one.id}", count: 0
  end

  test "should return empty when user follows no one" do
    get users_following_others_sleeps_url
    assert_response :success
    
    # Should not show any sleep records
    assert_select "div[id^='sleep_']", count: 0
  end

  test "should get index as json" do
    @user_one.following_others << @user_two
    
    get users_following_others_sleeps_url, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "should return empty json array when no followings" do
    get users_following_others_sleeps_url, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
    
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  test "should order sleep records by most recent first" do
    @user_one.following_others << @user_two
    
    # Create an older sleep record for user_two
    @user_two.sleeps.create!(
      started_at_raw: "2025-01-01 20:00:00",
    )
    
    get users_following_others_sleeps_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    # Should have sleeps ordered by started_at_utc desc
    timestamps = json_response.map { |sleep| sleep["started_at_utc"] }
    assert_equal timestamps.sort.reverse, timestamps
  end
end