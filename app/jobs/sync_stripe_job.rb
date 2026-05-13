class SyncStripeJob < ApplicationJob
  queue_as :billing

  def perform(user_id)
    user = User.find(user_id)

    Rails.logger.info("stripe_sync_requested user_id=#{user.id}")
  end
end
