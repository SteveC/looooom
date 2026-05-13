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
      requests = nil

      with_env("STRIPE_SECRET_KEY" => "sk_live_123", "STRIPE_ONE_TIME_AMOUNT_CENTS" => "1500") do
        stub_checkout_session(session) do |captured_requests|
          requests = captured_requests
          post billing_checkout_url(kind: "one_time")
        end
      end

      assert_redirected_to session.url
      assert_equal "payment", requests.first[:mode]
      assert_equal "cus_one", requests.first[:customer]
      assert_equal(
        [
          {
            price_data: {
              currency: "usd",
              product_data: { name: "loom one-time payment" },
              unit_amount: 1500
            },
            quantity: 1
          }
        ],
        requests.first[:line_items]
      )
      assert_equal({ user_id: @user.id, kind: "one_time", amount_cents: 1500, currency: "usd" }, requests.first[:metadata])
      assert_equal "stripe.checkout_started", @user.feature_usages.last.event_name
    end

    test "creates subscription checkout session with recurring inline price" do
      session = OpenStruct.new(id: "cs_live_sub", url: "https://checkout.stripe.com/c/pay/cs_live_sub")
      requests = nil

      with_env("STRIPE_SECRET_KEY" => "sk_live_123", "STRIPE_SUBSCRIPTION_AMOUNT_CENTS" => "900", "STRIPE_SUBSCRIPTION_INTERVAL" => "month") do
        stub_checkout_session(session) do |captured_requests|
          requests = captured_requests
          post billing_checkout_url(kind: "subscription")
        end
      end

      assert_redirected_to session.url
      assert_equal "subscription", requests.first[:mode]
      assert_equal(
        [
          {
            price_data: {
              currency: "usd",
              product_data: { name: "loom subscription" },
              unit_amount: 900,
              recurring: { interval: "month" }
            },
            quantity: 1
          }
        ],
        requests.first[:line_items]
      )
      assert_equal({ user_id: @user.id, kind: "subscription", amount_cents: 900, currency: "usd" }, requests.first[:subscription_data][:metadata])
    end

    test "requires configured amount" do
      with_env("STRIPE_SECRET_KEY" => "sk_live_123", "STRIPE_ONE_TIME_AMOUNT_CENTS" => nil) do
        post billing_checkout_url(kind: "one_time")
      end

      assert_redirected_to dashboard_url
      assert_equal "one_time amount is not configured", flash[:alert]
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

      requests = []
      Stripe::Checkout::Session.define_singleton_method(:create) do |params|
        requests << params
        result
      end

      yield requests
    ensure
      if original
        singleton.define_method(:create, original)
      else
        singleton.remove_method(:create)
      end
    end
  end
end
