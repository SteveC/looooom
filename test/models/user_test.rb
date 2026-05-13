require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "from_omniauth links an existing user by email" do
    user = users(:one)
    auth = omniauth_hash(email: user.email, uid: "google-123", name: "Google Name")

    assert_no_difference("User.count") do
      assert_equal user, User.from_omniauth(auth)
    end

    user.reload
    assert_equal "google_oauth2", user.provider
    assert_equal "google-123", user.uid
    assert_equal "Google Name", user.name
  end

  test "from_omniauth promotes configured admin email" do
    auth = omniauth_hash(email: "owner@example.com", uid: "google-owner", name: "Owner")

    with_env "ADMIN_EMAIL", "owner@example.com" do
      user = User.from_omniauth(auth)

      assert_predicate user, :admin?
      assert_predicate user, :configured_admin?
    end
  end

  test "configured_admin follows the current admin email environment variable" do
    user = users(:one)

    with_env "ADMIN_EMAIL", user.email.upcase do
      assert_predicate user, :configured_admin?
    end

    with_env "ADMIN_EMAIL", "someone-else@example.com" do
      assert_not user.configured_admin?
    end
  end

  private

  def omniauth_hash(email:, uid:, name:)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: {
        email: email,
        name: name
      },
    )
  end

  def with_env(key, value)
    previous = ENV[key]
    ENV[key] = value
    yield
  ensure
    ENV[key] = previous
  end
end
