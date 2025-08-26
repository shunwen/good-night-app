require "test_helper"

class FollowTest < ActiveSupport::TestCase
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @follow = Follow.new(@user_one)
  end

  test "should create valid follow relationship" do
    follow = @follow.create!(followed_id: @user_two.id)
    assert follow.valid?
    assert follow.save
    assert_equal @user_one, follow.follower
    assert_equal @user_two, follow.followed
  end

  test "should not allow following self" do
    assert_raises ArgumentError, match: /Cannot follow self/ do
      @follow.create!(followed_id: @user_one.id)
    end
  end

  test "should not allow duplicate follow relationships" do
    follow = @follow.create!(followed_id: @user_two.id)
    assert_raises(
      ActiveRecord::RecordInvalid,
      match: /Validation failed: Followed has already been taken/) do
      duplicate_follow = @follow.create!(followed_id: @user_two.id)
    end
  end

  test "should allow same user to be followed by different users" do
    follow1 = @follow.create!(followed_id: @user_two.id)
    assert follow1.valid?

    user_three = User.create!(name: "User Three")
    follow2 = user_three.follows.create!(followed_id: @user_two.id)
    assert follow2.valid?
  end

  test "should allow user to follow multiple different users" do
    follow1 = @follow.create!(followed_id: @user_two.id)
    assert follow1.valid?

    user_three = User.create!(name: "User Three")
    follow2 =@follow.create!(followed_id: user_three.id)
    assert follow2.valid?
  end
end
