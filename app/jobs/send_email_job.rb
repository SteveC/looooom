class SendEmailJob < ApplicationJob
  queue_as :mailers

  def perform(mailer_class, mailer_action, params = {})
    mailer_class.constantize.with(params).public_send(mailer_action).deliver_now
  end
end
