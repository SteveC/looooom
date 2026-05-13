class ChangeTicketReviewStatusDefaultToPending < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tickets, :review_status, from: "accepted", to: "pending"
  end
end
