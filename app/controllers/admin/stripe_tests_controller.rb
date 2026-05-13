module Admin
  class StripeTestsController < ApplicationController
    before_action :require_configured_admin!

    def create
      result = StripeSmokeTest.call
      mode = result.livemode ? "live" : "test"

      redirect_to admin_root_path,
                  notice: "Stripe test passed: authenticated in #{mode} mode with #{result.balance_count} balance entries."
    rescue StandardError => error
      Rails.logger.warn("admin_stripe_test_failed error=#{error.class}: #{error.message}")

      redirect_to admin_root_path, alert: "Stripe test failed: #{error.class}: #{error.message}"
    end
  end
end
