class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :status, null: false, default: "open"
      t.string :priority, null: false, default: "normal"

      t.timestamps
    end

    add_index :tickets, :status
    add_index :tickets, :priority
  end
end
