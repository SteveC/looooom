Rails.application.configure do
  if ENV["CLOUDFLARE_ACCOUNT_ID"].present? && ENV["CLOUDFLARE_API_TOKEN"].present?
    config.action_mailer.delivery_method = :cloudflare
    config.action_mailer.cloudflare_settings = {
      account_id: ENV.fetch("CLOUDFLARE_ACCOUNT_ID"),
      api_token: ENV.fetch("CLOUDFLARE_API_TOKEN")
    }
  end
end
