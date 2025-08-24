require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @user_two = users(:two)
    visit "/"

    page.driver.browser.manage.add_cookie(
      name: "user_id",
      value: @user.id.to_s,
      path: "/"
    )
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "should create user" do
    visit users_url
    click_on "New user"

    fill_in "Name", with: "Charlie"
    click_on "Create User"

    assert_text "User was successfully created"
    click_on "Back"
  end

  test "should destroy User" do
    visit user_url(@user_two)
    click_on "Destroy this user", match: :first

    assert_text "User was successfully destroyed"
  end
end
