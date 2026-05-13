require "test_helper"

module Admin
  class StorageTestsControllerTest < ActionDispatch::IntegrationTest
    test "redirects guests to sign in" do
      post admin_storage_test_url

      assert_redirected_to new_user_session_url
    end

    test "redirects signed in users who are not the configured admin" do
      with_env "ADMIN_EMAIL", "owner@example.com" do
        sign_in users(:one)

        post admin_storage_test_url

        assert_redirected_to dashboard_url
        assert_equal "Admin access required.", flash[:alert]
      end
    end

    test "configured admin can run storage test" do
      user = users(:one)

      with_env "ADMIN_EMAIL", user.email do
        sign_in user

        post admin_storage_test_url

        assert_redirected_to admin_root_url
        assert_match "Storage test passed", flash[:notice]
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
