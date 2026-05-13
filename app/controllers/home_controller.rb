class HomeController < ApplicationController
  def index
    @ticket_count = Ticket.accepted.count
    @shipped_count = Ticket.accepted.where(status: "shipped").count
    @vote_count = Vote.count
    @top_tickets = Ticket.accepted.openish.top.includes(:user).limit(5)
    @recent_tickets = Ticket.accepted.latest.includes(:user).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
  end
end
