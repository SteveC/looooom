class StripeWebhooksController < ApplicationController
  skip_forgery_protection

  def create
    event = construct_event
    StripeEventHandler.new(event).call

    head :ok
  rescue JSON::ParserError, KeyError, Stripe::SignatureVerificationError => error
    Rails.logger.warn("stripe_webhook_rejected error=#{error.class}: #{error.message}")
    head :bad_request
  end

  private

  def construct_event
    payload = request.raw_post
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")

    Stripe::Webhook.construct_event(payload, signature, endpoint_secret)
  end
end
