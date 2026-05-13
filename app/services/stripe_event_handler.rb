class StripeEventHandler
  def initialize(event)
    @event = event
  end

  def call
    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.created", "customer.subscription.updated", "customer.subscription.deleted"
      sync_subscription(event.data.object)
    when "invoice.payment_succeeded", "invoice.payment_failed"
      Rails.logger.info("stripe_invoice_event type=#{event.type} invoice_id=#{event.data.object.id}")
    else
      Rails.logger.info("stripe_event_ignored type=#{event.type}")
    end
  end

  private

  attr_reader :event

  def handle_checkout_completed(session)
    user = find_user(session)
    return unless user

    if session.mode == "subscription"
      upsert_subscription(user, session)
    else
      upsert_payment(user, session)
    end

    track(user, "stripe.checkout_completed", checkout_session_id: session.id, mode: session.mode)
  end

  def upsert_payment(user, session)
    payment = Payment.find_or_initialize_by(stripe_checkout_session_id: session.id)
    payment.update!(
      user: user,
      stripe_payment_intent_id: session.payment_intent,
      stripe_customer_id: session.customer,
      price_id: metadata_value(session, "price_id"),
      status: session.payment_status.presence || session.status,
      mode: session.mode,
      amount_total: session.amount_total,
      currency: session.currency
    )
  end

  def upsert_subscription(user, session)
    subscription = user.subscription || user.build_subscription
    subscription.update!(
      stripe_customer_id: session.customer,
      stripe_subscription_id: session.subscription,
      status: "active",
      plan: metadata_value(session, "kind").presence || "subscription"
    )
  end

  def sync_subscription(stripe_subscription)
    user = find_user(stripe_subscription)
    return unless user

    subscription = Subscription.find_or_initialize_by(stripe_subscription_id: stripe_subscription.id)
    subscription.user = user
    subscription.stripe_customer_id = stripe_subscription.customer
    subscription.status = stripe_subscription.status
    subscription.plan = plan_name(stripe_subscription)
    subscription.current_period_end = timestamp(stripe_subscription.current_period_end)
    subscription.save!

    track(user, "stripe.subscription_synced", subscription_id: stripe_subscription.id, status: stripe_subscription.status)
  end

  def find_user(object)
    user_id = metadata_value(object, "user_id") || object.try(:client_reference_id)
    return User.find_by(id: user_id) if user_id.present?

    Subscription.find_by(stripe_customer_id: object.customer)&.user
  end

  def plan_name(stripe_subscription)
    price = stripe_subscription.items&.data&.first&.price
    price&.lookup_key.presence || price&.nickname.presence || price&.id.presence || "subscription"
  end

  def timestamp(value)
    Time.zone.at(value) if value.present?
  end

  def metadata_value(object, key)
    metadata = object.try(:metadata)
    return if metadata.blank?

    if metadata.respond_to?(:fetch)
      metadata.fetch(key, nil)
    else
      metadata[key]
    end
  end

  def track(user, event_name, metadata)
    user.feature_usages.create!(event_name: event_name, metadata: metadata, occurred_at: Time.current)
  rescue ActiveRecord::ActiveRecordError => error
    Rails.logger.warn("stripe_usage_track_failed event=#{event_name} error=#{error.class}: #{error.message}")
  end
end
