require "test_helper"
require "ostruct"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "records completed one-time checkout" do
    user = users(:one)
    session = stripe_object(
      id: "cs_live_new",
      mode: "payment",
      customer: "cus_one",
      payment_intent: "pi_live_new",
      payment_status: "paid",
      status: "complete",
      amount_total: 1500,
      currency: "usd",
      client_reference_id: user.id.to_s,
      metadata: { "user_id" => user.id.to_s, "kind" => "one_time", "price_id" => "price_once" }
    )
    event = stripe_event("checkout.session.completed", session)

    with_env("STRIPE_WEBHOOK_SECRET" => "whsec_123") do
      stub_stripe_webhook(event) do
        assert_difference("Payment.count") do
          post stripe_webhook_url, params: "{}", headers: { "Stripe-Signature" => "sig" }
        end
      end
    end

    assert_response :success
    payment = Payment.find_by!(stripe_checkout_session_id: "cs_live_new")
    assert_equal user, payment.user
    assert_equal "paid", payment.status
    assert_equal 1500, payment.amount_total
  end

  test "syncs subscription updates" do
    user = users(:two)
    subscription = stripe_object(
      id: "sub_two",
      customer: "cus_two",
      status: "active",
      current_period_end: 1.month.from_now.to_i,
      metadata: { "user_id" => user.id.to_s },
      items: stripe_object(
        data: [
          stripe_object(price: stripe_object(id: "price_monthly", lookup_key: "pro_monthly", nickname: nil))
        ]
      )
    )
    event = stripe_event("customer.subscription.updated", subscription)

    with_env("STRIPE_WEBHOOK_SECRET" => "whsec_123") do
      stub_stripe_webhook(event) do
        post stripe_webhook_url, params: "{}", headers: { "Stripe-Signature" => "sig" }
      end
    end

    assert_response :success
    record = user.subscription.reload
    assert_equal "active", record.status
    assert_equal "pro_monthly", record.plan
  end

  test "rejects invalid signatures" do
    with_env("STRIPE_WEBHOOK_SECRET" => "whsec_123") do
      stub_stripe_webhook(->(*) { raise Stripe::SignatureVerificationError.new("bad", "sig") }) do
        post stripe_webhook_url, params: "{}", headers: { "Stripe-Signature" => "bad" }
      end
    end

    assert_response :bad_request
  end

  private

  def stripe_event(type, object)
    stripe_object(type: type, data: stripe_object(object: object))
  end

  def stripe_object(attributes)
    OpenStruct.new(attributes)
  end

  def stub_stripe_webhook(result)
    singleton = class << Stripe::Webhook; self end
    original = Stripe::Webhook.method(:construct_event) if Stripe::Webhook.respond_to?(:construct_event)

    Stripe::Webhook.define_singleton_method(:construct_event) do |*args|
      result.respond_to?(:call) ? result.call(*args) : result
    end

    yield
  ensure
    if original
      singleton.define_method(:construct_event, original)
    else
      singleton.remove_method(:construct_event)
    end
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
