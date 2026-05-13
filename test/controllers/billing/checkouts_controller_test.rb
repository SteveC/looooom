require "test_helper"
require "ostruct"

module Billing
  class CheckoutsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      sign_in @user
    end

    test "creates one-time checkout session" do
      session = OpenStruct.new(id: "cs_live_one", url: "https://checkout.stripe.com/c/pay/cs_live_one")

      with_env("STRIPE_SECRET_KEY" => "sk_live_123", "STRIPE_ONE_TIME_PRICE_ID" => "price_once") do
        stub_checkout_session(session) do
          post billing_checkout_url(kind: "one_time")
        end
      end

      assert_redirected_to session.url
      assert_equal "stripe.checkout_started", @user.feature_usages.last.event_name
    end

    test "requires configured price" do
      with_env("STRIPE_SECRET_KEY" => "sk_live_123", "STRIPE_ONE_TIME_PRICE_ID" => nil) do
        post billing_checkout_url(kind: "one_time")
      end

      assert_redirected_to dashboard_url
      assert_equal "one_time price is not configured", flash[:alert]
    end

    private

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

    def stub_checkout_session(result)
      singleton = class << Stripe::Checkout::Session; self end
      original = Stripe::Checkout::Session.method(:create) if Stripe::Checkout::Session.respond_to?(:create)

      Stripe::Checkout::Session.define_singleton_method(:create) { |*| result }

      yield
    ensure
      if original
        singleton.define_method(:create, original)
      else
        singleton.remove_method(:create)
      end
    end
  end
end
