class FeatureUsage < ApplicationRecord
  belongs_to :user

  validates :event_name, presence: true
  validates :occurred_at, presence: true

  before_validation :set_defaults

  scope :recent, -> { where(occurred_at: 7.days.ago..) }

  private

  def set_defaults
    self.occurred_at ||= Time.current
    self.metadata ||= {}
  end
end
