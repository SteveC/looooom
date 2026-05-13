class CreateTicketComments < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :hidden, null: false, default: false

      t.timestamps
    end

    add_index :ticket_comments, [ :ticket_id, :created_at ]
    add_index :ticket_comments, :hidden
  end
end
