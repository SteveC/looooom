class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAILER_FROM", "hello@looooom.local") }
  layout "mailer"
end
