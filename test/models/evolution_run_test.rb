require "test_helper"

class EvolutionRunTest < ActiveSupport::TestCase
  test "successful run marks linked ticket shipped" do
    ticket = tickets(:one)
    ticket.update!(status: "open")

    EvolutionRun.create!(ticket: ticket, status: "succeeded", branch_name: "main", summary: "Fixed the bug.")

    assert_equal "shipped", ticket.reload.status
  end

  test "failed run leaves linked ticket open" do
    ticket = tickets(:one)
    ticket.update!(status: "open")

    EvolutionRun.create!(ticket: ticket, status: "failed", branch_name: "main", summary: "Could not fix safely.")

    assert_equal "open", ticket.reload.status
  end
end
