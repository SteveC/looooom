class StripeCheckout
  CheckoutConfig = Data.define(:mode, :price_id, :success_message)

  def self.configured?
    ENV["STRIPE_SECRET_KEY"].present?
  end

  def self.config_for(kind)
    case kind
    when "one_time"
      CheckoutConfig.new(
        mode: "payment",
        price_id: ENV["STRIPE_ONE_TIME_PRICE_ID"],
        success_message: "Thanks for supporting loom."
      )
    when "subscription"
      CheckoutConfig.new(
        mode: "subscription",
        price_id: ENV["STRIPE_SUBSCRIPTION_PRICE_ID"],
        success_message: "Subscription checkout started."
      )
    end
  end

  def self.price_configured?(kind)
    config_for(kind)&.price_id.present?
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
    raise ArgumentError, "#{kind} price is not configured" if config.price_id.blank?

    customer_id = ensure_customer_id

    Stripe::Checkout::Session.create(
      mode: config.mode,
      customer: customer_id,
      client_reference_id: user.id.to_s,
      line_items: [ { price: config.price_id, quantity: 1 } ],
      success_url: url_helpers.dashboard_url(checkout: "success"),
      cancel_url: url_helpers.dashboard_url(checkout: "cancelled"),
      metadata: metadata,
      subscription_data: subscription_data(config)
    )
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
      price_id: self.class.config_for(kind).price_id
    }
  end

  def subscription_data(config)
    return nil unless config.mode == "subscription"

    { metadata: metadata }
  end
end
