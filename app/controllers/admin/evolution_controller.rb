module Admin
  class EvolutionController < ApplicationController
    before_action :require_admin!

    def index
      @evolution_logs = EvolutionLog.latest.limit(25)
      @open_tickets = Ticket.openish.latest.limit(10)
      @usage_events = FeatureUsage.recent.group(:event_name).count
    end

    def create
      EvolutionAnalysisJob.perform_later(trigger: "manual", requested_by_id: current_user.id)

      redirect_to admin_evolution_path, notice: "Evolution analysis queued."
    end
  end
end
