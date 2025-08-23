require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "follow the other user" do
    @user = users(:one)
    @other_user = users(:two)

    @user.following_others << @other_user

    assert @other_user.followers.include?(@user)
  end
end
