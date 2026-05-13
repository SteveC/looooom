class HomeController < ApplicationController
  def index
    @ticket_count = Ticket.count
    @shipped_count = Ticket.where(status: "shipped").count
    @evolution_count = EvolutionLog.count
  end
end
