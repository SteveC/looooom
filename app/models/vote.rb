class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :ticket, counter_cache: true

  validates :user_id, uniqueness: { scope: :ticket_id }
end
