class AddVotesCountToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :votes_count, :integer, null: false, default: 0
  end
end
