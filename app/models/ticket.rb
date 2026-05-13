class Ticket < ApplicationRecord
  STATUSES = %w[open planned in_progress shipped closed].freeze
  PRIORITIES = %w[low normal high urgent].freeze

  belongs_to :user
  has_many :votes, dependent: :destroy

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validate :content_must_be_allowed

  scope :latest, -> { order(created_at: :desc) }
  scope :top, -> { order(votes_count: :desc, created_at: :desc) }
  scope :openish, -> { where(status: %w[open planned in_progress]) }

  def voted_by?(user)
    return false unless user

    votes.exists?(user: user)
  end

  private

  def content_must_be_allowed
    result = ContentPolicy.check(title, description)
    return if result.allowed?

    errors.add(:base, result.message)
  end
end
