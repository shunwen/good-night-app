require "test_helper"

class FollowTest < ActiveSupport::TestCase
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
  end

  test "should create valid follow relationship" do
    follow = Follow.new(follower: @user_one, followed: @user_two)
    assert follow.valid?
    assert follow.save
  end

  test "should belong to follower user" do
    follow = Follow.create!(follower: @user_one, followed: @user_two)
    assert_equal @user_one, follow.follower
    assert_kind_of User, follow.follower
  end

  test "should belong to followed user" do
    follow = Follow.create!(follower: @user_one, followed: @user_two)
    assert_equal @user_two, follow.followed
    assert_kind_of User, follow.followed
  end

  test "should require follower" do
    follow = Follow.new(followed: @user_two)
    assert_not follow.valid?
    assert_includes follow.errors[:follower], "must exist"
  end

  test "should require followed" do
    follow = Follow.new(follower: @user_one)
    assert_not follow.valid?
    assert_includes follow.errors[:followed], "must exist"
  end

  test "should not allow following self" do
    follow = Follow.new(follower: @user_one, followed: @user_one)
    assert_not follow.valid?
    assert_includes follow.errors[:follower], "can't be the same as followed"
  end

  test "should not allow duplicate follow relationships" do
    # Create first follow relationship
    Follow.create!(follower: @user_one, followed: @user_two)
    
    # Attempt to create duplicate
    duplicate_follow = Follow.new(follower: @user_one, followed: @user_two)
    assert_not duplicate_follow.valid?
    assert_includes duplicate_follow.errors[:followed_id], "has already been taken"
  end

  test "should allow same user to be followed by different users" do
    # User one follows user two
    follow1 = Follow.create!(follower: @user_one, followed: @user_two)
    assert follow1.valid?
    
    # Create a third user
    user_three = User.create!(name: "User Three")
    
    # User three also follows user two (should be allowed)
    follow2 = Follow.new(follower: user_three, followed: @user_two)
    assert follow2.valid?
    assert follow2.save
  end

  test "should allow user to follow multiple different users" do
    # User one follows user two
    follow1 = Follow.create!(follower: @user_one, followed: @user_two)
    assert follow1.valid?
    
    # Create a third user
    user_three = User.create!(name: "User Three")
    
    # User one also follows user three (should be allowed)
    follow2 = Follow.new(follower: @user_one, followed: user_three)
    assert follow2.valid?
    assert follow2.save
  end

  test "should be destroyed when follower is destroyed" do
    follow = Follow.create!(follower: @user_one, followed: @user_two)
    follow_id = follow.id
    
    assert_difference("Follow.count", -1) do
      @user_one.destroy
    end
    
    assert_nil Follow.find_by(id: follow_id)
  end

  test "should be destroyed when followed user is destroyed" do
    follow = Follow.create!(follower: @user_one, followed: @user_two)
    follow_id = follow.id
    
    assert_difference("Follow.count", -1) do
      @user_two.destroy
    end
    
    assert_nil Follow.find_by(id: follow_id)
  end
end
