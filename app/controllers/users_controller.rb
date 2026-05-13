class UsersController < ApplicationController
  def show
    @user = User.find_by!(slug: params.expect(:slug))
    @karma_breakdown = @user.karma_breakdown
    @public_ticket_count = @user.tickets.accepted.count
    @comment_count = @user.ticket_comments.visible.count
    @votes_received_count = @user.tickets.sum(:votes_count)
    @tickets = @user.tickets.accepted.latest.limit(20)
    @comments = @user.ticket_comments.visible.latest.includes(:ticket).limit(20)
  end
end
