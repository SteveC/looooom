class AdminMailer < ApplicationMailer
  def cloudflare_test(recipient:, sent_at: Time.current)
    @sent_at = sent_at

    mail(to: recipient, subject: "loom Cloudflare email test") do |format|
      format.text { render plain: text_body }
      format.html { render html: html_body.html_safe }
    end
  end

  private

  def text_body
    <<~TEXT
      This is a test email from loom.

      Cloudflare Email Service accepted a send request from the admin dashboard at #{@sent_at.iso8601}.
    TEXT
  end

  def html_body
    <<~HTML
      <p>This is a test email from loom.</p>
      <p>Cloudflare Email Service accepted a send request from the admin dashboard at <strong>#{ERB::Util.html_escape(@sent_at.iso8601)}</strong>.</p>
    HTML
  end
end
