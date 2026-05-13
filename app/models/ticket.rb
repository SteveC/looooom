class Ticket < ApplicationRecord
  STATUSES = %w[open planned in_progress shipped closed].freeze
  PRIORITIES = %w[low normal high urgent].freeze

  belongs_to :user

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  scope :latest, -> { order(created_at: :desc) }
  scope :openish, -> { where(status: %w[open planned in_progress]) }
end
