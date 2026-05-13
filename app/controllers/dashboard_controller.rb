class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    track_usage("dashboard.viewed")

    @tickets = current_user.admin? ? Ticket.latest.limit(8) : current_user.tickets.latest.limit(8)
    @open_ticket_count = current_user.admin? ? Ticket.openish.count : current_user.tickets.openish.count
    @usage_events = current_user.feature_usages.recent.group(:event_name).count
    @latest_evolution = EvolutionLog.latest.limit(5)
  end
end
