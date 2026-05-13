class TicketTriageJob < ApplicationJob
  queue_as :default

  def perform(ticket_id)
    ticket = Ticket.find(ticket_id)
    return unless ticket.review_status == "pending"
    return unless Openai::Client.configured?

    moderation = Openai::TicketModerator.new(ticket).call
    if moderation[:flagged]
      ticket.hold!(review_status: "spam", reason: "OpenAI moderation flagged this ticket.", metadata: { moderation: moderation })
      return
    end

    Openai::TicketEmbedding.new(ticket).call
    duplicate = Openai::TicketDuplicateDetector.new(ticket).call
    if duplicate
      ticket.hold!(
        review_status: "duplicate",
        reason: "Likely duplicate of ticket ##{duplicate.fetch(:ticket).id}.",
        duplicate_ticket: duplicate.fetch(:ticket),
        metadata: { duplicate_similarity: duplicate.fetch(:score) }
      )
      return
    end

    SubmitTicketTriageBatchJob.perform_later
  end
end
