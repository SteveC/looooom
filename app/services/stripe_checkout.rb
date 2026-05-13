class StripeCheckout
  def self.configured?
    ENV["STRIPE_SECRET_KEY"].present?
  end

  def initialize(user:, kind:, url_helpers:)
    @user = user
    @kind = kind
    @url_helpers = url_helpers
  end

  def create_session
    raise ArgumentError, "Stripe is not configured" unless self.class.configured?

    offer = BillingOffer.available.find_by(key: kind)
    raise ArgumentError, "Unknown checkout offer" unless offer

    customer_id = ensure_customer_id

    Stripe::Checkout::Session.create({
      mode: offer.mode,
      customer: customer_id,
      client_reference_id: user.id.to_s,
      line_items: [ line_item(offer) ],
      success_url: url_helpers.dashboard_url(checkout: "success"),
      cancel_url: url_helpers.dashboard_url(checkout: "cancelled"),
      metadata: metadata(offer),
      subscription_data: subscription_data(offer)
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

  def metadata(offer)
    {
      user_id: user.id,
      kind: offer.key,
      amount_cents: offer.amount_cents,
      currency: offer.currency
    }
  end

  def subscription_data(offer)
    return nil unless offer.subscription?

    { metadata: metadata(offer) }
  end

  def line_item(offer)
    price_data = {
      currency: offer.currency,
      product_data: {
        name: offer.product_name
      },
      unit_amount: offer.amount_cents
    }
    price_data[:recurring] = { interval: offer.recurring_interval } if offer.subscription?

    { price_data: price_data, quantity: 1 }
  end
end
