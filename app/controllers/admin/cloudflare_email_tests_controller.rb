module Admin
  class CloudflareEmailTestsController < ApplicationController
    before_action :require_configured_admin!

    def create
      result = CloudflareEmailSmokeTest.call

      redirect_to admin_root_path,
                  notice: "Cloudflare email test #{result.status}: sent from #{result.from} to #{result.recipient}."
    rescue StandardError => error
      Rails.logger.warn("admin_cloudflare_email_test_failed error=#{error.class}: #{error.message}")

      redirect_to admin_root_path, alert: "Cloudflare email test failed: #{error.class}: #{error.message}"
    end
  end
end
