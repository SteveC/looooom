class AllowInvoiceOnlyPayments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :payments, :stripe_checkout_session_id, true
  end
end
