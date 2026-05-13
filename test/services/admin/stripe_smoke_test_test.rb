require "test_helper"
require "ostruct"

module Admin
  class StripeSmokeTestTest < ActiveSupport::TestCase
    test "retrieves balance without creating stripe objects" do
      with_env "STRIPE_SECRET_KEY", "sk_live_123" do
        stub_stripe_balance(livemode: true, available_count: 1, pending_count: 1) do
          result = StripeSmokeTest.call

          assert_predicate result, :livemode
          assert_equal 2, result.balance_count
          assert_equal "sk_live_123", Stripe.api_key
        end
      end
    end

    test "fails clearly when stripe secret key is missing" do
      with_env "STRIPE_SECRET_KEY", nil do
        error = assert_raises(RuntimeError) { StripeSmokeTest.call }

        assert_equal "STRIPE_SECRET_KEY is not configured", error.message
      end
    end

    private

    def stub_stripe_balance(livemode:, available_count:, pending_count:)
      singleton = class << Stripe::Balance; self end
      original = Stripe::Balance.method(:retrieve)

      Stripe::Balance.define_singleton_method(:retrieve) do
        OpenStruct.new(
          livemode: livemode,
          available: Array.new(available_count) { OpenStruct.new },
          pending: Array.new(pending_count) { OpenStruct.new },
        )
      end

      yield
    ensure
      singleton.define_method(:retrieve, original)
    end

    def with_env(key, value)
      previous = ENV[key]
      ENV[key] = value
      yield
    ensure
      ENV[key] = previous
    end
  end
end
