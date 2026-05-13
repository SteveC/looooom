class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    track_usage("dashboard.viewed")

    @tickets = Ticket.top.limit(8)
    @my_tickets = current_user.tickets.latest.limit(8)
    @open_ticket_count = Ticket.openish.count
    @vote_count = Vote.count
    @usage_events = current_user.feature_usages.recent.group(:event_name).count
    @subscription = current_user.subscription
    @payments = current_user.payments.order(created_at: :desc).limit(5)
    @billing_offers = BillingOffer.available
  end
end
