class EvolutionRun < ApplicationRecord
  belongs_to :ticket, optional: true

  STATUSES = %w[reported running succeeded failed opened_pr merged reverted].freeze
  CLOSING_STATUSES = %w[succeeded merged].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :pull_request_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  before_validation :set_defaults
  after_create :mark_ticket_shipped

  scope :latest, -> { order(created_at: :desc) }

  private

  def set_defaults
    self.status ||= "reported"
    self.runner_metadata ||= {}
  end

  def mark_ticket_shipped
    return unless ticket
    return unless status.in?(CLOSING_STATUSES)
    return if ticket.closed?

    ticket.update!(status: "shipped")
  end
end
