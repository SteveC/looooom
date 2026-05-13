class UsersController < ApplicationController
  def show
    @user = User.find_by!(slug: params.expect(:slug))
    @tickets = @user.tickets.accepted.latest.limit(20)
    @comments = @user.ticket_comments.visible.latest.includes(:ticket).limit(20)
  end
end
