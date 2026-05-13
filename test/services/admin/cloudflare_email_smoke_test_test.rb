require "test_helper"

module Admin
  class CloudflareEmailSmokeTestTest < ActiveSupport::TestCase
    test "sends a raw mime test email through cloudflare" do
      calls = []

      with_env(
        "CLOUDFLARE_ACCOUNT_ID" => "account_123",
        "CLOUDFLARE_API_TOKEN" => "token_123",
        "MAILER_FROM" => "hello@example.com",
      ) do
        stub_cloudflare_email(calls: calls, delivered: [ CloudflareEmailSmokeTest::RECIPIENT ]) do
          result = CloudflareEmailSmokeTest.call

          assert_equal CloudflareEmailSmokeTest::RECIPIENT, result.recipient
          assert_equal "hello@example.com", result.from
          assert_equal "delivered", result.status
        end
      end

      assert_equal 1, calls.size
      assert_equal "hello@example.com", calls.first.fetch(:from)
      assert_equal [ CloudflareEmailSmokeTest::RECIPIENT ], calls.first.fetch(:recipients)
      assert_includes calls.first.fetch(:mime_message), "loom Cloudflare email test"
    end

    test "fails clearly when mailer sender is missing" do
      with_env(
        "CLOUDFLARE_ACCOUNT_ID" => "account_123",
        "CLOUDFLARE_API_TOKEN" => "token_123",
        "MAILER_FROM" => nil,
      ) do
        error = assert_raises(RuntimeError) { CloudflareEmailSmokeTest.call }

        assert_equal "MAILER_FROM is not configured", error.message
      end
    end

    private

    def stub_cloudflare_email(calls:, delivered:)
      stub = Struct.new(:calls, :delivered) do
        def send_raw(*, **payload)
          calls << payload
          Cloudflare::Email::Response.new({
            "success" => true,
            "result" => {
              "delivered" => delivered,
              "queued" => [],
              "permanent_bounces" => []
            }
          })
        end
      end
      original = Cloudflare::Email::Client.method(:new)
      singleton = class << Cloudflare::Email::Client; self end

      Cloudflare::Email::Client.define_singleton_method(:new) { |**| stub.new(calls, delivered) }

      yield
    ensure
      singleton.define_method(:new, original)
    end

    def with_env(values)
      previous = values.transform_values { nil }
      values.each do |key, value|
        previous[key] = ENV[key]
        ENV[key] = value
      end

      yield
    ensure
      previous.each { |key, value| ENV[key] = value }
    end
  end
end
