require "test_helper"
require "ostruct"

module Admin
  class StripeTestsControllerTest < ActionDispatch::IntegrationTest
    test "redirects guests to sign in" do
      post admin_stripe_test_url

      assert_redirected_to new_user_session_url
    end

    test "redirects signed in users who are not the configured admin" do
      with_env "ADMIN_EMAIL" => "owner@example.com" do
        sign_in users(:one)

        post admin_stripe_test_url

        assert_redirected_to dashboard_url
        assert_equal "Admin access required.", flash[:alert]
      end
    end

    test "configured admin can run stripe test" do
      user = users(:one)

      with_env "ADMIN_EMAIL" => user.email, "STRIPE_SECRET_KEY" => "sk_live_123" do
        stub_stripe_balance(livemode: true) do
          sign_in user

          post admin_stripe_test_url
        end
      end

      assert_redirected_to admin_root_url
      assert_match "Stripe test passed", flash[:notice]
      assert_match "live mode", flash[:notice]
    end

    private

    def stub_stripe_balance(livemode:)
      singleton = class << Stripe::Balance; self end
      original = Stripe::Balance.method(:retrieve)

      Stripe::Balance.define_singleton_method(:retrieve) do
        OpenStruct.new(livemode: livemode, available: [ OpenStruct.new ], pending: [])
      end

      yield
    ensure
      singleton.define_method(:retrieve, original)
    end

    def with_env(values)
      previous = values.transform_values { nil }
      values.each do |key, value|
        previous[key] = ENV[key]
        ENV[key] = value
      end

      yield
    ensure
      previous.each { |key, value| ENV[key] = value }
    end
  end
end
