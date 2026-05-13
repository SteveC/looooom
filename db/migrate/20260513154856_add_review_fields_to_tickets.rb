class AddReviewFieldsToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :review_status, :string, null: false, default: "accepted"
    add_reference :tickets, :duplicate_ticket, null: true, foreign_key: { to_table: :tickets }
    add_column :tickets, :review_reason, :text
    add_column :tickets, :reviewed_at, :datetime
    add_column :tickets, :accepted_at, :datetime
    add_column :tickets, :ai_review_metadata, :jsonb, null: false, default: {}
    add_column :tickets, :embedding, :jsonb
    add_column :tickets, :embedding_model, :string
    add_column :tickets, :comments_count, :integer, null: false, default: 0

    add_index :tickets, :review_status
    add_index :tickets, :accepted_at
  end
end
