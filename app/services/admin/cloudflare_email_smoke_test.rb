module Admin
  class CloudflareEmailSmokeTest
    RECIPIENT = "steve@stevecoast.com".freeze
    Result = Struct.new(:recipient, :from, :status, keyword_init: true)

    def self.call
      new.call
    end

    def call
      require_env!("CLOUDFLARE_ACCOUNT_ID")
      require_env!("CLOUDFLARE_API_TOKEN")
      require_env!("MAILER_FROM")

      mail = AdminMailer.cloudflare_test(recipient: RECIPIENT)
      response = client.send_raw(
        from: mail.from.first,
        recipients: mail.destinations,
        mime_message: mail.encoded,
      )

      raise "Cloudflare returned an unsuccessful response" unless response.success?
      raise "Cloudflare permanently bounced #{response.permanent_bounces.join(", ")}" if response.permanent_bounces.any?

      Result.new(recipient: RECIPIENT, from: mail.from.first, status: delivery_status(response))
    end

    private

    def require_env!(key)
      raise "#{key} is not configured" if ENV[key].blank?
    end

    def client
      Cloudflare::Email::Client.new(
        account_id: ENV.fetch("CLOUDFLARE_ACCOUNT_ID"),
        api_token: ENV.fetch("CLOUDFLARE_API_TOKEN"),
        retries: 0,
      )
    end

    def delivery_status(response)
      return "delivered" if response.delivered.any?
      return "queued" if response.queued.any?

      "accepted"
    end
  end
end
