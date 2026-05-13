class StripeCheckout
  CheckoutConfig = Data.define(:mode, :amount_cents, :currency, :product_name, :recurring_interval, :success_message)

  def self.configured?
    ENV["STRIPE_SECRET_KEY"].present?
  end

  def self.config_for(kind)
    case kind
    when "one_time"
      CheckoutConfig.new(
        mode: "payment",
        amount_cents: amount_cents("STRIPE_ONE_TIME_AMOUNT_CENTS"),
        currency: currency,
        product_name: ENV["STRIPE_ONE_TIME_PRODUCT_NAME"].presence || "loom one-time payment",
        recurring_interval: nil,
        success_message: "Thanks for supporting loom."
      )
    when "subscription"
      CheckoutConfig.new(
        mode: "subscription",
        amount_cents: amount_cents("STRIPE_SUBSCRIPTION_AMOUNT_CENTS"),
        currency: currency,
        product_name: ENV["STRIPE_SUBSCRIPTION_PRODUCT_NAME"].presence || "loom subscription",
        recurring_interval: ENV["STRIPE_SUBSCRIPTION_INTERVAL"].presence || "month",
        success_message: "Subscription checkout started."
      )
    end
  end

  def self.price_configured?(kind)
    config_for(kind)&.amount_cents.present?
  end

  def self.amount_cents(key)
    value = ENV[key]
    return if value.blank?

    Integer(value, exception: false)
  end

  def self.currency
    ENV["STRIPE_CURRENCY"].presence || "usd"
  end

  def initialize(user:, kind:, url_helpers:)
    @user = user
    @kind = kind
    @url_helpers = url_helpers
  end

  def create_session
    raise ArgumentError, "Stripe is not configured" unless self.class.configured?

    config = self.class.config_for(kind)
    raise ArgumentError, "Unknown checkout kind" unless config
    raise ArgumentError, "#{kind} amount is not configured" unless valid_amount?(config.amount_cents)

    customer_id = ensure_customer_id

    Stripe::Checkout::Session.create({
      mode: config.mode,
      customer: customer_id,
      client_reference_id: user.id.to_s,
      line_items: [ line_item(config) ],
      success_url: url_helpers.dashboard_url(checkout: "success"),
      cancel_url: url_helpers.dashboard_url(checkout: "cancelled"),
      metadata: metadata,
      subscription_data: subscription_data(config)
    }.compact)
  end

  private

  attr_reader :user, :kind, :url_helpers

  def ensure_customer_id
    subscription = user.subscription || user.build_subscription(status: "free", plan: "free")
    return subscription.stripe_customer_id if subscription.stripe_customer_id.present?

    customer = Stripe::Customer.create(email: user.email, name: user.name, metadata: { user_id: user.id })
    subscription.update!(stripe_customer_id: customer.id)
    customer.id
  end

  def metadata
    {
      user_id: user.id,
      kind: kind,
      amount_cents: self.class.config_for(kind).amount_cents,
      currency: self.class.config_for(kind).currency
    }
  end

  def subscription_data(config)
    return nil unless config.mode == "subscription"

    { metadata: metadata }
  end

  def line_item(config)
    price_data = {
      currency: config.currency,
      product_data: {
        name: config.product_name
      },
      unit_amount: config.amount_cents
    }
    price_data[:recurring] = { interval: config.recurring_interval } if config.mode == "subscription"

    { price_data: price_data, quantity: 1 }
  end

  def valid_amount?(amount_cents)
    amount_cents.is_a?(Integer) && amount_cents.positive?
  end
end
