class ProcessTicketJob < ApplicationJob
  queue_as :default

  def perform(ticket_id)
    ticket = Ticket.find(ticket_id)

    EvolutionAnalysisJob.perform_later(trigger: "ticket", ticket_id: ticket.id)
  end
end
