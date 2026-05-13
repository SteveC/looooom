class Subscription < ApplicationRecord
  belongs_to :user

  validates :status, presence: true
  validates :plan, presence: true
  validates :stripe_subscription_id, uniqueness: true, allow_blank: true
end
