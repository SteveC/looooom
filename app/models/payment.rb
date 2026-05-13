class Payment < ApplicationRecord
  belongs_to :user

  validates :stripe_checkout_session_id, presence: true, uniqueness: true
  validates :status, presence: true
  validates :mode, presence: true
end
