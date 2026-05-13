module Billing
  class CheckoutsController < ApplicationController
    before_action :authenticate_user!

    def create
      kind = params.expect(:kind)

      session = StripeCheckout.new(user: current_user, kind: kind, url_helpers: self).create_session
      track_usage("stripe.checkout_started", kind: kind, checkout_session_id: session.id)

      redirect_to session.url, allow_other_host: true
    rescue ArgumentError => error
      redirect_to dashboard_path, alert: error.message
    rescue Stripe::StripeError => error
      Rails.logger.warn("stripe_checkout_failed user_id=#{current_user.id} error=#{error.class}: #{error.message}")
      redirect_to dashboard_path, alert: "Stripe checkout could not be started."
    end
  end
end
