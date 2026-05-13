class AddStripeInvoiceIdToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :stripe_invoice_id, :string
    add_index :payments, :stripe_invoice_id, unique: true
  end
end
