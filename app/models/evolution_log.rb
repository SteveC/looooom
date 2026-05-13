class EvolutionLog < ApplicationRecord
  STATUSES = %w[queued running completed failed skipped].freeze

  validates :trigger, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :latest, -> { order(created_at: :desc) }

  def duration
    return unless started_at && finished_at

    finished_at - started_at
  end
end
