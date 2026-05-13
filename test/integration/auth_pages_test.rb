require "test_helper"

class AuthPagesTest < ActionDispatch::IntegrationTest
  test "registration page renders without oauth credentials" do
    get new_user_registration_url

    assert_response :success
    assert_select "h2", "Sign up"
  end

  test "session page renders without oauth credentials" do
    get new_user_session_url

    assert_response :success
    assert_select "h2", "Log in"
  end
end
