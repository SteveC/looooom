class OpenaiBatchJob < ApplicationRecord
  STATUSES = %w[queued submitted validating in_progress finalizing completed failed expired cancelled].freeze

  validates :purpose, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :openai_batch_id, uniqueness: true, allow_blank: true

  before_validation :set_defaults

  scope :active, -> { where(status: %w[queued submitted validating in_progress finalizing]) }

  def active?
    status.in?(%w[queued submitted validating in_progress finalizing])
  end

  private

  def set_defaults
    self.status ||= "queued"
    self.metadata ||= {}
  end
end
