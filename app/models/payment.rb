class Payment < ApplicationRecord
  belongs_to :user

  validates :stripe_checkout_session_id, uniqueness: true, allow_blank: true
  validates :stripe_invoice_id, uniqueness: true, allow_blank: true
  validates :status, presence: true
  validates :mode, presence: true
  validate :stripe_reference_present

  private

  def stripe_reference_present
    return if stripe_checkout_session_id.present? || stripe_invoice_id.present?

    errors.add(:base, "Stripe checkout session or invoice is required")
  end
end
