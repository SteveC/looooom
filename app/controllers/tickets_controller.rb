class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[ show edit update destroy ]

  # GET /tickets or /tickets.json
  def index
    @tickets = ticket_scope.latest.includes(:user)
  end

  # GET /tickets/1 or /tickets/1.json
  def show
  end

  # GET /tickets/new
  def new
    @ticket = current_user.tickets.new(status: "open", priority: "normal")
  end

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets or /tickets.json
  def create
    @ticket = current_user.tickets.new(ticket_params)

    respond_to do |format|
      if @ticket.save
        track_usage("ticket.created", ticket_id: @ticket.id, priority: @ticket.priority)
        ProcessTicketJob.perform_later(@ticket.id)

        format.html { redirect_to @ticket, notice: "Ticket was created and queued for analysis." }
        format.json { render :show, status: :created, location: @ticket }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tickets/1 or /tickets/1.json
  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        track_usage("ticket.updated", ticket_id: @ticket.id, status: @ticket.status)

        format.html { redirect_to @ticket, notice: "Ticket was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1 or /tickets/1.json
  def destroy
    @ticket.destroy!

    respond_to do |format|
      format.html { redirect_to tickets_path, notice: "Ticket was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = ticket_scope.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def ticket_params
      permitted = [ :title, :description, :priority ]
      permitted << :status if current_user&.admin?

      params.expect(ticket: permitted)
    end

    def ticket_scope
      current_user.admin? ? Ticket.all : current_user.tickets
    end
end
