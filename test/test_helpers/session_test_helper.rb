module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in(user)
    # Use the sessions controller to properly sign in during tests
    post session_path, params: { user_id: user.id }, as: :json
  end
end
