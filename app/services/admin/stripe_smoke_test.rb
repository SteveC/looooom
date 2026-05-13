module Admin
  class StripeSmokeTest
    Result = Struct.new(:livemode, :balance_count, keyword_init: true)

    def self.call
      new.call
    end

    def call
      raise "STRIPE_SECRET_KEY is not configured" if ENV["STRIPE_SECRET_KEY"].blank?

      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
      balance = Stripe::Balance.retrieve

      Result.new(
        livemode: balance.livemode,
        balance_count: Array(balance.available).count + Array(balance.pending).count,
      )
    end
  end
end
