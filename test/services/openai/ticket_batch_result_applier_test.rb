require "test_helper"

module Openai
  class TicketBatchResultApplierTest < ActiveSupport::TestCase
    test "applies accepted batch result" do
      ticket = tickets(:two)
      ticket.update!(review_status: "pending", accepted_at: nil)
      batch = openai_batch_jobs(:one)
      content = JSON.generate(
        {
          custom_id: "ticket-#{ticket.id}",
          response: {
            body: {
              output: [
                {
                  content: [
                    {
                      text: JSON.generate({ decision: "accepted", reason: "Clear product feedback.", duplicate_ticket_id: nil })
                    }
                  ]
                }
              ]
            }
          }
        }
      )

      TicketBatchResultApplier.new(batch, "#{content}\n").call

      assert_equal "accepted", ticket.reload.review_status
      assert_equal "Clear product feedback.", ticket.review_reason
    end

    test "applies duplicate batch result" do
      ticket = tickets(:two)
      ticket.update!(review_status: "pending", accepted_at: nil)
      duplicate = tickets(:one)
      batch = openai_batch_jobs(:one)
      content = JSON.generate(
        {
          custom_id: "ticket-#{ticket.id}",
          response: {
            body: {
              output: [
                {
                  content: [
                    {
                      text: JSON.generate({ decision: "duplicate", reason: "Same request.", duplicate_ticket_id: duplicate.id })
                    }
                  ]
                }
              ]
            }
          }
        }
      )

      TicketBatchResultApplier.new(batch, "#{content}\n").call

      assert_equal "duplicate", ticket.reload.review_status
      assert_equal duplicate, ticket.duplicate_ticket
    end
  end
end
