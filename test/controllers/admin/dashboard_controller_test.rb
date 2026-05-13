require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    test "redirects guests to sign in" do
      get admin_root_url

      assert_redirected_to new_user_session_url
    end

    test "redirects signed in users who are not the configured admin" do
      with_env "ADMIN_EMAIL", "owner@example.com" do
        sign_in users(:admin)

        get admin_root_url

        assert_redirected_to dashboard_url
        assert_equal "Admin access required.", flash[:alert]
      end
    end

    test "shows dashboard to configured admin" do
      user = users(:one)

      with_env "ADMIN_EMAIL", user.email do
        sign_in user

        get admin_root_url

        assert_response :success
        assert_select "h1", "Admin dashboard"
        assert_select "p", text: /#{Regexp.escape(user.email)}/
        assert_select "h2", "Recent users"
        assert_select "h2", "Top tickets"
        assert_select "h2", "Usage events"
        assert_select "form[action=?]", admin_storage_test_path
        assert_select "form[action=?]", admin_stripe_test_path
        assert_select "form[action=?]", admin_cloudflare_email_test_path
        assert_select "a[href=?]", admin_root_path
      end
    end

    test "hides admin navigation from non configured users" do
      with_env "ADMIN_EMAIL", "owner@example.com" do
        sign_in users(:one)

        get dashboard_url

        assert_response :success
        assert_select "a[href=?]", admin_root_path, false
      end
    end

    private

    def with_env(key, value)
      previous = ENV[key]
      ENV[key] = value
      yield
    ensure
      ENV[key] = previous
    end
  end
end
