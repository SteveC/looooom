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

  test "new users get a generated public username" do
    user = User.create!(email: "fresh@example.com", password: "password123")

    assert_match(/\A[a-z]+-[a-z]+-\d{2}\z/, user.username)
    assert_nil user.username_changed_at
  end

  test "username can be changed once and is normalized" do
    user = users(:one)

    assert user.update(username: "Heavy Banana 56")
    assert_equal "heavy-banana-56", user.username
    assert_not_nil user.username_changed_at

    assert_not user.update(username: "quiet-river-22")
    assert_includes user.errors[:username], "can only be changed once"
  end

  test "karma score rewards tickets approval votes and comments" do
    user = users(:one)

    assert_equal({
      tickets: 3,
      accepted_tickets: 12,
      shipped_tickets: 0,
      votes_cast: 0,
      votes_received: 1,
      comments: 2
    }, user.karma_breakdown)
    assert_equal 18, user.karma_score
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
