class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_checkout_session_id, null: false
      t.string :stripe_payment_intent_id
      t.string :stripe_customer_id
      t.string :price_id
      t.string :status, null: false, default: "pending"
      t.string :mode, null: false, default: "payment"
      t.integer :amount_total
      t.string :currency

      t.timestamps
    end

    add_index :payments, :stripe_checkout_session_id, unique: true
    add_index :payments, :stripe_payment_intent_id
    add_index :payments, :stripe_customer_id
    add_index :payments, :status
  end
end
