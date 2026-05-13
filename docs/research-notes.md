# Research Notes

Research pass performed on May 13, 2026 before writing the initial project documents.

## Rails

Rails 8 is real and current, with RubyGems listing Rails 8.1.3 and 8.0.x releases. Rails Guides state that Rails 8.0 and 8.1 require Ruby 3.2.0 or newer. The local machine currently has system Ruby 2.6.10 active, so the Rails app should not be generated until a modern Ruby is installed or activated.

Sources:

* https://guides.rubyonrails.org/upgrading_ruby_on_rails.html
* https://rubygems.org/gems/rails

## Cloudflare Email Service

Cloudflare Email Service is documented as beta, with outbound email available through REST API and Workers bindings. The docs explicitly warn that beta features and APIs may change before general availability.

Sources:

* https://developers.cloudflare.com/email-service/
* https://developers.cloudflare.com/api/resources/email_sending/methods/send/

## cloudflare-email Gem

The `cloudflare-email` gem exists and presents itself as a Rails integration for Cloudflare Email Service, including Action Mailer delivery and Action Mailbox ingress support. It is very new, with low adoption indicators, so production implementation should verify current maintenance and fallback options before relying on it.

Source:

* https://www.ruby-toolbox.com/projects/cloudflare-email

