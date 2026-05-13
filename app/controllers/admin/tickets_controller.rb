module Admin
  class TicketsController < ApplicationController
    before_action :require_configured_admin!
    before_action :set_ticket, only: :update

    def index
      @tickets = Ticket.pending_review.latest.includes(:user, :duplicate_ticket).limit(100)
    end

    def update
      case params.expect(:review_status)
      when "accepted"
        @ticket.accept!(reason: review_reason.presence || "Accepted by admin.", metadata: { admin_reviewed: true })
      when "held", "spam", "rejected"
        @ticket.hold!(review_status: params[:review_status], reason: review_reason, metadata: { admin_reviewed: true })
      when "duplicate"
        duplicate = Ticket.accepted.find(params.expect(:duplicate_ticket_id))
        @ticket.hold!(review_status: "duplicate", reason: review_reason.presence || "Duplicate ticket.", duplicate_ticket: duplicate, metadata: { admin_reviewed: true })
      else
        raise ActionController::BadRequest, "Unknown review status"
      end

      track_usage("admin.ticket_reviewed", ticket_id: @ticket.id, review_status: @ticket.review_status)
      redirect_back fallback_location: admin_tickets_path, notice: "Ticket review updated."
    end

    private

    def set_ticket
      @ticket = Ticket.find(params.expect(:id))
    end

    def review_reason
      params[:review_reason].to_s
    end
  end
end
