require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "shows public user page without exposing email" do
    get user_url(users(:one))

    assert_response :success
    assert_select "h1", "one user"
    assert_select "p", "@one-user"
    assert_select "p", "Karma"
    assert_select "body", text: /one@example.com/, count: 0
  end
end
