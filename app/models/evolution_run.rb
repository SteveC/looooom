class EvolutionRun < ApplicationRecord
  belongs_to :ticket, optional: true

  STATUSES = %w[reported running succeeded failed opened_pr merged reverted].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :pull_request_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  before_validation :set_defaults

  scope :latest, -> { order(created_at: :desc) }

  private

  def set_defaults
    self.status ||= "reported"
    self.runner_metadata ||= {}
  end
end
