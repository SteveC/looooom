class Ticket < ApplicationRecord
  STATUSES = %w[open planned in_progress shipped closed].freeze
  PRIORITIES = %w[low normal high urgent].freeze
  REVIEW_STATUSES = %w[pending accepted held spam duplicate rejected].freeze

  belongs_to :user
  belongs_to :duplicate_ticket, class_name: "Ticket", optional: true
  has_many :votes, dependent: :destroy
  has_many :comments, class_name: "TicketComment", dependent: :destroy
  has_many :evolution_runs, dependent: :nullify

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :review_status, inclusion: { in: REVIEW_STATUSES }
  validates :duplicate_ticket, presence: true, if: -> { review_status == "duplicate" }
  validate :content_must_be_allowed

  before_validation :set_defaults

  scope :latest, -> { order(created_at: :desc) }
  scope :top, -> { order(votes_count: :desc, created_at: :desc) }
  scope :openish, -> { where(status: %w[open planned in_progress]) }
  scope :closedish, -> { where(status: %w[shipped closed]) }
  scope :accepted, -> { where(review_status: "accepted") }
  scope :pending_review, -> { where(review_status: %w[pending held spam duplicate rejected]) }
  scope :implementation_candidates, lambda {
    threshold = ENV.fetch("TICKET_IMPLEMENTATION_VOTE_THRESHOLD", 2).to_i
    accepted.where("votes_count >= ? OR priority = ?", threshold, "urgent")
  }

  def voted_by?(user)
    return false unless user

    votes.exists?(user: user)
  end

  def visible_to?(viewer)
    accepted? || owner_or_admin?(viewer)
  end

  def editable_by?(viewer)
    owner_or_admin?(viewer)
  end

  def commentable_by?(viewer)
    return false unless viewer

    accepted? || owner_or_admin?(viewer)
  end

  def accepted?
    review_status == "accepted"
  end

  def closed?
    status.in?(%w[shipped closed])
  end

  def accept!(reason: nil, metadata: {})
    update!(
      review_status: "accepted",
      review_reason: reason,
      reviewed_at: Time.current,
      accepted_at: accepted_at || Time.current,
      ai_review_metadata: ai_review_metadata.merge(metadata)
    )
  end

  def hold!(review_status:, reason:, duplicate_ticket: nil, metadata: {})
    update!(
      review_status: review_status,
      review_reason: reason,
      duplicate_ticket: duplicate_ticket,
      reviewed_at: Time.current,
      ai_review_metadata: ai_review_metadata.merge(metadata)
    )
  end

  def reopen!
    update!(status: "open")
  end

  private

  def owner_or_admin?(viewer)
    viewer && (viewer.admin? || user == viewer)
  end

  def set_defaults
    self.status ||= "open"
    self.priority ||= "normal"
    self.review_status ||= "pending"
    self.ai_review_metadata ||= {}
    self.accepted_at ||= Time.current if accepted?
  end

  def content_must_be_allowed
    result = ContentPolicy.check(title, description)
    return if result.allowed?

    errors.add(:base, result.message)
  end
end
