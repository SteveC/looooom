require "test_helper"

class AdminMailerTest < ActionMailer::TestCase
  test "cloudflare test email renders recipient and sender" do
    with_env "MAILER_FROM", "hello@example.com" do
      mail = AdminMailer.cloudflare_test(
        recipient: Admin::CloudflareEmailSmokeTest::RECIPIENT,
        sent_at: Time.zone.parse("2026-05-13 12:00:00"),
      )

      assert_equal [ Admin::CloudflareEmailSmokeTest::RECIPIENT ], mail.to
      assert_equal [ "hello@example.com" ], mail.from
      assert_equal "loom Cloudflare email test", mail.subject
      assert_match "This is a test email from loom.", mail.text_part.body.to_s
    end
  end

  private

  def with_env(key, value)
    previous = ENV[key]
    ENV[key] = value
    yield
  ensure
    ENV[key] = previous
  end
end
