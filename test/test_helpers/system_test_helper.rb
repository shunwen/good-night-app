module SystemTestHelper
  def sign_in(user)
    # Visit the sign-in page and authenticate
    visit new_session_path
    fill_in "User ID", with: user.id
    click_button "Sign In"

    # Should redirect to root with success message
    assert_text "Signed in successfully"
  end
end
