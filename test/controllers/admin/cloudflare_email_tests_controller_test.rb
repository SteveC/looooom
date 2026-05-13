require "test_helper"

module Admin
  class CloudflareEmailTestsControllerTest < ActionDispatch::IntegrationTest
    test "redirects guests to sign in" do
      post admin_cloudflare_email_test_url

      assert_redirected_to new_user_session_url
    end

    test "redirects signed in users who are not the configured admin" do
      with_env "ADMIN_EMAIL" => "owner@example.com" do
        sign_in users(:one)

        post admin_cloudflare_email_test_url

        assert_redirected_to dashboard_url
        assert_equal "Admin access required.", flash[:alert]
      end
    end

    test "configured admin can send cloudflare email test" do
      user = users(:one)

      with_env "ADMIN_EMAIL" => user.email,
               "CLOUDFLARE_ACCOUNT_ID" => "account_123",
               "CLOUDFLARE_API_TOKEN" => "token_123",
               "MAILER_FROM" => "hello@example.com" do
        stub_cloudflare_email(delivered: [ Admin::CloudflareEmailSmokeTest::RECIPIENT ]) do
          sign_in user

          post admin_cloudflare_email_test_url
        end
      end

      assert_redirected_to admin_root_url
      assert_match "Cloudflare email test delivered", flash[:notice]
      assert_match Admin::CloudflareEmailSmokeTest::RECIPIENT, flash[:notice]
    end

    private

    def stub_cloudflare_email(delivered:)
      stub = Struct.new(:delivered) do
        def send_raw(*, **)
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

      Cloudflare::Email::Client.define_singleton_method(:new) { |**| stub.new(delivered) }

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
