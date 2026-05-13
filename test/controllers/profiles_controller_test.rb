require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "shows edit username form when change is available" do
    get edit_profile_url

    assert_response :success
    assert_select "input[name='user[username]']"
  end

  test "updates username once" do
    patch profile_url, params: { user: { username: "Heavy Banana 56" } }

    assert_redirected_to user_url(@user.reload)
    assert_equal "heavy-banana-56", @user.username
    assert_not_nil @user.username_changed_at
  end

  test "does not allow a second username update" do
    @user.update!(username: "heavy-banana-56")

    patch profile_url, params: { user: { username: "quiet-river-22" } }

    assert_response :unprocessable_entity
    assert_equal "heavy-banana-56", @user.reload.username
  end
end
