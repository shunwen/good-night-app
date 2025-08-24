require "test_helper"

class Users::FollowingOthers::PrevWeekSleepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @sleep_one = sleeps(:one)
    @sleep_two = sleeps(:two)
    cookies[:user_id] = @user_one.id
  end

  test "should get index when user has followings with sleeps" do
    @user_one.following_others << @user_two
    get users_following_others_prev_week_sleeps_url
    assert_response :success
  end

  test "should show only sleep records from followed users within previous week" do
    @user_one.following_others << @user_two
    
    # Create a sleep record from previous week for user_two
    prev_week_sleep = @user_two.sleeps.create!(
      started_at_raw: Time.current.prev_week.beginning_of_week.strftime("%Y-%m-%d 22:00:00"),
      stopped_at_raw: Time.current.prev_week.beginning_of_week.strftime("%Y-%m-%d 06:00:00")
    )
    
    get users_following_others_prev_week_sleeps_url
    assert_response :success
    
    # Should include sleep from followed user (user_two) from previous week
    assert_select "div#sleep_#{prev_week_sleep.id}", count: 1
    
    # Should not include own sleep record (user_one)
    assert_select "div#sleep_#{@sleep_one.id}", count: 0
  end

  test "should return empty when user follows no one" do
    get users_following_others_prev_week_sleeps_url
    assert_response :success
    
    # Should not show any sleep records
    assert_select "div[id^='sleep_']", count: 0
  end

  test "should get index as json" do
    @user_one.following_others << @user_two
    
    get users_following_others_prev_week_sleeps_url, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "should return empty json array when no followings" do
    get users_following_others_prev_week_sleeps_url, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
    
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  test "should only show sleep records from previous week" do
    @user_one.following_others << @user_two
    
    prev_week_start = Time.current.prev_week.beginning_of_week
    
    # Sleep from previous week (should be included)
    prev_week_sleep = @user_two.sleeps.create!(
      started_at_raw: prev_week_start.strftime("%Y-%m-%d 22:00:00"),
      stopped_at_raw: (prev_week_start + 1.day).strftime("%Y-%m-%d 06:00:00")
    )
    
    # Sleep from this week (should be excluded)
    this_week_sleep = @user_two.sleeps.create!(
      started_at_raw: Time.current.beginning_of_week.strftime("%Y-%m-%d 22:00:00"),
      stopped_at_raw: Time.current.beginning_of_week.strftime("%Y-%m-%d 06:00:00")
    )
    
    # Sleep from two weeks ago (should be excluded)
    two_weeks_ago_sleep = @user_two.sleeps.create!(
      started_at_raw: (Time.current - 2.weeks).strftime("%Y-%m-%d 22:00:00"),
      stopped_at_raw: (Time.current - 2.weeks).strftime("%Y-%m-%d 06:00:00")
    )
    
    get users_following_others_prev_week_sleeps_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    sleep_ids = json_response.map { |sleep| sleep["id"] }
    
    # Should only include previous week sleep
    assert_includes sleep_ids, prev_week_sleep.id
    assert_not_includes sleep_ids, this_week_sleep.id
    assert_not_includes sleep_ids, two_weeks_ago_sleep.id
    assert_equal 1, json_response.length
  end

  test "should order sleep records by duration descending" do
    @user_one.following_others << @user_two
    
    # Create sleep records from previous week with different durations
    prev_week_start = Time.current.prev_week.beginning_of_week
    
    # Shorter sleep (6 hours)
    short_sleep = @user_two.sleeps.create!(
      started_at_raw: prev_week_start.strftime("%Y-%m-%d 23:00:00"),
      stopped_at_raw: (prev_week_start + 1.day).strftime("%Y-%m-%d 05:00:00")
    )
    
    # Longer sleep (8 hours)
    long_sleep = @user_two.sleeps.create!(
      started_at_raw: (prev_week_start + 1.day).strftime("%Y-%m-%d 22:00:00"),
      stopped_at_raw: (prev_week_start + 2.days).strftime("%Y-%m-%d 06:00:00")
    )
    
    get users_following_others_prev_week_sleeps_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    # Should have sleeps ordered by duration desc (longest first)
    durations = json_response.map { |sleep| sleep["duration"] }
    assert_equal durations.sort.reverse, durations
    assert_equal long_sleep.id, json_response.first["id"]
    assert_equal short_sleep.id, json_response.last["id"]
  end
end
