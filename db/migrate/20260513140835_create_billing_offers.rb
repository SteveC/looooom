class CreateBillingOffers < ActiveRecord::Migration[8.1]
  def up
    create_table :billing_offers do |t|
      t.string :key, null: false
      t.string :mode, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "usd"
      t.string :product_name, null: false
      t.string :button_label, null: false
      t.string :recurring_interval
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :billing_offers, :key, unique: true
    add_index :billing_offers, [ :active, :position ]

    execute <<~SQL.squish
      INSERT INTO billing_offers
        (key, mode, amount_cents, currency, product_name, button_label, recurring_interval, active, position, created_at, updated_at)
      VALUES
        ('one_time', 'payment', 1500, 'usd', 'loom one-time payment', 'One-time payment', NULL, TRUE, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('subscription', 'subscription', 900, 'usd', 'loom subscription', 'Subscribe', 'month', TRUE, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
  end

  def down
    drop_table :billing_offers
  end
end
