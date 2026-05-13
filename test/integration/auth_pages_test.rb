require "test_helper"

class AuthPagesTest < ActionDispatch::IntegrationTest
  test "session page renders google-only login" do
    get new_user_session_url

    assert_response :success
    assert_select "h1", "Sign in with Google"
    assert_select "input[type=password]", count: 0
  end

  test "registration and password pages are not routed" do
    get "/users/sign_up"
    assert_response :not_found

    get "/users/password/new"
    assert_response :not_found
  end

  test "password sign in is rejected" do
    post user_session_url, params: { user: { email: users(:one).email, password: "password123" } }

    assert_redirected_to new_user_session_url
    follow_redirect!
    assert_select "#alert", "Use Google to sign in to loom."
  end
end
