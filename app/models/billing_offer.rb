class BillingOffer < ApplicationRecord
  MODES = %w[payment subscription].freeze
  RECURRING_INTERVALS = %w[day week month year].freeze

  scope :available, -> { where(active: true).order(:position, :id) }

  validates :key, presence: true, uniqueness: true
  validates :mode, presence: true, inclusion: { in: MODES }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, format: { with: /\A[a-z]{3}\z/ }
  validates :product_name, presence: true
  validates :button_label, presence: true
  validates :recurring_interval, inclusion: { in: RECURRING_INTERVALS }, allow_blank: true
  validates :recurring_interval, presence: true, if: :subscription?

  before_validation :normalize_currency

  def subscription?
    mode == "subscription"
  end

  private

  def normalize_currency
    self.currency = currency.to_s.downcase.presence
  end
end
