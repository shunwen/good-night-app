require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "follow and unfollow the other user" do
    @user = users(:one)
    @other_user = users(:two)

    @user.follow(@other_user)

    assert @user.following?(@other_user)

    @user.unfollow(@other_user)

    assert_not @user.following?(@other_user)
  end
end
