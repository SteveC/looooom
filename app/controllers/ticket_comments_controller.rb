class TicketCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket

  def create
    @comment = @ticket.comments.new(comment_params.merge(user: current_user))

    if @comment.save
      track_usage("ticket.comment_created", ticket_id: @ticket.id)
      redirect_to @ticket, notice: "Comment added."
    else
      @comments = @ticket.comments.visible.chronological.includes(:user)
      @evolution_runs = @ticket.evolution_runs.latest
      render "tickets/show", status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params.expect(:ticket_id))
    raise ActiveRecord::RecordNotFound unless @ticket.visible_to?(current_user)
    raise ActiveRecord::RecordNotFound unless @ticket.commentable_by?(current_user)
  end

  def comment_params
    params.expect(ticket_comment: [ :body ])
  end
end
