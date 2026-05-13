class HomeController < ApplicationController
  def index
    @ticket_count = Ticket.count
    @shipped_count = Ticket.where(status: "shipped").count
    @vote_count = Vote.count
  end
end
