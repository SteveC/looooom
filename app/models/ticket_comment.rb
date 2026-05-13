class TicketComment < ApplicationRecord
  belongs_to :ticket, counter_cache: :comments_count
  belongs_to :user

  validates :body, presence: true, length: { maximum: 4_000 }

  scope :visible, -> { where(hidden: false) }
  scope :latest, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }
end
